<script setup lang="ts">
import{fetchQuiz,isCorrect,type LoadedQuiz} from "~/composables/useQuiz";
import{useRoleStore} from "~/stores/role";

const route=useRoute();
const roleStore=useRoleStore();
const supabase=useSupabaseClient();
const quizId=route.query.id as string;
const challengeId=route.query.challenge as string|undefined;

const quiz=ref<LoadedQuiz|null>(null);
const errorMessage=ref('');
const count=ref(0);
const answers=ref<string[]>([]);
const revealed=ref(false);
const submitQuiz=ref(false);
const saving=ref(false);
const outcome=ref(''); // challenge result text once known

const current=computed(()=>quiz.value?.questions[count.value]);
const isLast=computed(()=>quiz.value && count.value>=quiz.value.questions.length-1);
const correct=computed(()=>quiz.value?quiz.value.questions.filter((q,i)=>isCorrect(q,answers.value[i])).length:0);
const score=computed(()=>correct.value*10);

onMounted(async ()=>{
  try{
    quiz.value=await fetchQuiz(quizId,supabase);

    if(challengeId)
    {
      const{data:challenge}=await supabase.from('challenge').select('*').eq('id',challengeId).single();
      const myScore=challenge?.challenger_id==roleStore.id?challenge?.challenger_score:challenge?.reciever_score;
      if(myScore!=null)
      {
        errorMessage.value='You have already played this challenge.';
      }
    }
  }
  catch(error)
  {
    console.log(error);
    errorMessage.value=`We couldn't load this quiz. ${error?.message??''}`;
  }
});

function checkAnswer()
{
  revealed.value=true;
}

function next()
{
  if(isLast.value)
  {
    quizComplete();
    return;
  }
  revealed.value=false;
  count.value++;
}

async function saveChallenge()
{
  const{data:challenge}=await supabase.from('challenge').select('*').eq('id',challengeId).single();
  if(!challenge) return;

  const iAmChallenger=challenge.challenger_id==roleStore.id;
  const myColumn=iAmChallenger?'challenger_score':'reciever_score';
  const theirScore=iAmChallenger?challenge.reciever_score:challenge.challenger_score;
  const update:Record<string,any>={[myColumn]:correct.value};

  if(theirScore==null)
  {
    outcome.value='Your score is in. We\'ll show the result once your opponent has played.';
  }
  else
  {
    const opponentId=iAmChallenger?challenge.reciever_id:challenge.challenger_id;
    update.status='completed';
    update.winner=correct.value>theirScore?roleStore.id:correct.value<theirScore?opponentId:null;
    outcome.value=correct.value>theirScore
        ?`You won! Your opponent got ${theirScore} right.`
        :correct.value<theirScore
            ?`You lost. Your opponent got ${theirScore} right.`
            :`It's a draw. You both got ${theirScore} right.`;
  }

  const{error}=await supabase.from('challenge').update(update).eq('id',challengeId);
  if(error) console.log(error);
}

async function quizComplete()
{
  submitQuiz.value=true;
  saving.value=true;
  try {
    if(challengeId)
    {
      await saveChallenge();
    }
    const{error}=await supabase.rpc('update_stats',{
      profile_id:roleStore.id,
      points_to_add:score.value,
      games_to_add:1
    });
    if(error) console.log(error);
  }
  catch(error){
    console.log(error);
  }
  saving.value=false;
}
</script>

<template>
  <div class="page max-w-3xl flex-1 flex flex-col justify-center">
    <div v-if="errorMessage" class="card p-8 text-center">
      <p class="font-bold">{{errorMessage}}</p>
      <NuxtLink to="/home" class="btn-secondary mt-4">Back to home</NuxtLink>
    </div>

    <div v-else-if="!quiz" class="text-center text-cocoa-500">Loading quiz…</div>

    <!-- Results -->
    <div v-else-if="submitQuiz" class="card p-8 text-center">
      <img src="/rabbit.png" alt="" class="h-28 w-28 mx-auto">
      <h1 class="text-4xl font-bold mt-2">Quiz complete!</h1>
      <p class="text-cocoa-500 mt-1">{{quiz.name}}</p>

      <div class="grid grid-cols-2 gap-3 my-6 max-w-sm mx-auto">
        <div class="rounded-2xl bg-cocoa-50 p-4">
          <p class="text-xs font-bold uppercase tracking-wide text-cocoa-500">Correct</p>
          <p class="font-display text-3xl font-bold">{{correct}}/{{quiz.questions.length}}</p>
        </div>
        <div class="rounded-2xl bg-amber-100 p-4">
          <p class="text-xs font-bold uppercase tracking-wide text-amber-800">Points</p>
          <p class="font-display text-3xl font-bold">+{{score}}</p>
        </div>
      </div>

      <p v-if="saving" class="text-cocoa-500">Saving your score…</p>
      <p v-else-if="outcome" class="font-bold">{{outcome}}</p>

      <div class="flex flex-wrap justify-center gap-3 mt-6">
        <NuxtLink to="/home" class="btn-secondary">Back to home</NuxtLink>
        <NuxtLink to="/quiz" class="btn-primary">Play another</NuxtLink>
      </div>
    </div>

    <!-- Question -->
    <div v-else>
      <QuestionCard
          v-model="answers[count]"
          :question="current"
          :number="count+1"
          :total="quiz.questions.length"
          :revealed="revealed"
      />

      <div class="mt-6 flex items-center justify-between gap-4">
        <p class="font-bold" :class="!revealed?'invisible':isCorrect(current,answers[count])?'text-emerald-700':'text-red-600'">
          {{isCorrect(current,answers[count])?'Correct! +10':'Not quite.'}}
        </p>
        <button v-if="!revealed" class="btn-primary !px-8" :disabled="!answers[count]" @click="checkAnswer">Check answer</button>
        <button v-else class="btn-primary !px-8" @click="next">{{isLast?'See results':'Next question'}}</button>
      </div>
    </div>
  </div>
</template>
