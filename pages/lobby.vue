<script setup lang="ts">
import type {RealtimeChannel} from "@supabase/supabase-js";
import{fetchQuiz,isCorrect,type LoadedQuiz} from "~/composables/useQuiz";
import{useRoleStore} from "~/stores/role";

// Live 1v1 game. Each quiz has its own realtime room:
//  - presence tracks who is in the room; the first two to join play
//  - the player who joined first is the host: creates the challenge row,
//    sends "start" and saves the final scores
//  - each player broadcasts "answer" when they lock in; once both have
//    answered a question, both clients reveal it and move on together

const route=useRoute();
const roleStore=useRoleStore();
const supabase=useSupabaseClient();
const quizId=route.query.id as string;
const myId=String(roleStore.id);

const quiz=ref<LoadedQuiz|null>(null);
const players=ref<{id:string,name:string,joined_at:number}[]>([]);
const phase=ref<'waiting'|'playing'|'finished'|'full'|'left'>('waiting');
const challengeId=ref<number|null>(null);
const count=ref(0);
const myAnswers=ref<string[]>([]);
const results=ref<Record<number,Record<string,boolean>>>({}); // question index -> player id -> correct
const revealed=ref(false);
const errorMessage=ref('');

let channel:RealtimeChannel|null=null;
let starting=false;
let advanceTimer:ReturnType<typeof setTimeout>|null=null;

const me=computed(()=>players.value.find((p)=>p.id===myId));
const opponent=computed(()=>players.value.find((p)=>p.id!==myId));
const isHost=computed(()=>players.value[0]?.id===myId);
const current=computed(()=>quiz.value?.questions[count.value]);
const total=computed(()=>quiz.value?.questions.length??0);
const lockedIn=computed(()=>results.value[count.value]?.[myId]!=null);
const opponentLockedIn=computed(()=>opponent.value && results.value[count.value]?.[opponent.value.id]!=null);

function scoreFor(id?:string)
{
  if(!id) return 0;
  return Object.values(results.value).filter((r)=>r[id]).length;
}
const myScore=computed(()=>scoreFor(myId));
const theirScore=computed(()=>scoreFor(opponent.value?.id));

function syncPlayers()
{
  const state=channel!.presenceState<{id:string,name:string,joined_at:number}>();
  const everyone=Object.values(state).map((entries)=>entries[0]).sort((a,b)=>a.joined_at-b.joined_at);

  if(phase.value==='playing' && !everyone.some((p)=>p.id===opponent.value?.id))
  {
    phase.value='left';
    return;
  }
  if(phase.value!=='waiting') return;

  players.value=everyone.slice(0,2);
  if(!players.value.some((p)=>p.id===myId) && everyone.some((p)=>p.id===myId))
  {
    phase.value='full';
    return;
  }
  if(players.value.length===2 && isHost.value)
  {
    startGame();
  }
}

async function startGame()
{
  if(starting) return;
  starting=true;
  const{data,error}=await supabase.from('challenge').insert({
    quiz_id:Number(quizId),
    challenger_id:Number(myId),
    reciever_id:Number(opponent.value!.id),
    status:'live'
  }).select('id').single();
  if(error)
  {
    console.log(error);
    errorMessage.value='Could not start the game.';
    starting=false;
    return;
  }
  await channel!.send({type:'broadcast',event:'start',payload:{challengeId:data.id,players:players.value}});
}

function onStart(payload)
{
  if(!payload.players.some((p)=>p.id===myId))
  {
    phase.value='full';
    return;
  }
  challengeId.value=payload.challengeId;
  players.value=payload.players;
  count.value=0;
  results.value={};
  myAnswers.value=[];
  revealed.value=false;
  phase.value='playing';
}

function onAnswer(payload)
{
  const{id,question,correct}=payload;
  results.value={...results.value,[question]:{...results.value[question],[id]:correct}};

  const both=players.value.every((p)=>results.value[question]?.[p.id]!=null);
  if(both && question===count.value && !revealed.value)
  {
    revealed.value=true;
    advanceTimer=setTimeout(advance,2500);
  }
}

function advance()
{
  if(count.value>=total.value-1)
  {
    finish();
    return;
  }
  count.value++;
  revealed.value=false;
}

async function lockIn()
{
  if(lockedIn.value || !current.value) return;
  await channel!.send({
    type:'broadcast',
    event:'answer',
    payload:{id:myId,question:count.value,correct:isCorrect(current.value,myAnswers.value[count.value])}
  });
}

async function finish()
{
  phase.value='finished';
  if(!isHost.value) return;

  // only the host saves, so nothing gets counted twice
  const host=players.value[0].id;
  const guest=players.value[1].id;
  const hostScore=scoreFor(host);
  const guestScore=scoreFor(guest);
  const winner=hostScore>guestScore?host:guestScore>hostScore?guest:null;

  const{error}=await supabase.from('challenge').update({
    challenger_score:hostScore,
    reciever_score:guestScore,
    winner:winner?Number(winner):null,
    status:'completed'
  }).eq('id',challengeId.value);
  if(error) console.log(error);

  for(const [id,points] of [[host,hostScore],[guest,guestScore]])
  {
    const{error:statsError}=await supabase.rpc('update_stats',{profile_id:Number(id),points_to_add:points*10,games_to_add:1});
    if(statsError) console.log(statsError);
  }
}

onMounted(async ()=>{
  try{
    quiz.value=await fetchQuiz(quizId,supabase);
  }
  catch(error)
  {
    console.log(error);
    errorMessage.value=`We couldn't load this quiz. ${error?.message??''}`;
    return;
  }

  channel=supabase.channel(`quiz-lobby-${quizId}`,{
    config:{broadcast:{self:true},presence:{key:myId}}
  });
  channel
      .on('presence',{event:'sync'},syncPlayers)
      .on('broadcast',{event:'start'},({payload})=>onStart(payload))
      .on('broadcast',{event:'answer'},({payload})=>onAnswer(payload))
      .subscribe(async (status)=>{
        if(status==='SUBSCRIBED')
        {
          await channel!.track({id:myId,name:roleStore.name,joined_at:Date.now()});
        }
      });
});

onBeforeUnmount(()=>{
  if(advanceTimer) clearTimeout(advanceTimer);
  if(channel) supabase.removeChannel(channel);
});
</script>

<template>
  <div class="page max-w-3xl flex-1 flex flex-col justify-center">
    <div v-if="errorMessage" class="card p-8 text-center">
      <p class="font-bold">{{errorMessage}}</p>
      <NuxtLink to="/quiz" class="btn-secondary mt-4">Back to quizzes</NuxtLink>
    </div>

    <!-- Waiting room -->
    <div v-else-if="phase==='waiting'" class="card p-8 text-center">
      <img src="/rabbit.png" alt="" class="h-24 w-24 mx-auto animate-bounce">
      <span class="pill bg-rose-100 text-rose-700 mt-2">Live match</span>
      <h1 class="text-3xl font-bold mt-2">{{quiz?.name??'Loading…'}}</h1>
      <p class="text-cocoa-500 mt-1">Waiting for an opponent to join this quiz…</p>

      <div class="grid grid-cols-2 gap-3 mt-6 max-w-sm mx-auto">
        <div v-for="slot in 2" :key="slot" class="rounded-2xl border-2 p-4" :class="players[slot-1]?'border-amber-300 bg-amber-50':'border-dashed border-cocoa-200'">
          <p class="font-bold truncate">{{players[slot-1]?.name||(players[slot-1]?'Player':'Open slot')}}</p>
          <p class="text-xs text-cocoa-500">{{players[slot-1]?.id===myId?'You':players[slot-1]?'Ready':'…'}}</p>
        </div>
      </div>
      <p class="text-sm text-cocoa-500 mt-6">Tell a friend to pick <b>{{quiz?.name}}</b> and choose <b>Play live</b>.</p>
      <NuxtLink to="/quiz" class="inline-block mt-4 text-sm font-bold text-cocoa-500 hover:text-cocoa-900">← Leave</NuxtLink>
    </div>

    <div v-else-if="phase==='full'" class="card p-8 text-center">
      <p class="font-bold">This match is already full.</p>
      <p class="text-cocoa-500 mt-1">Two players are already playing this quiz live. Try again in a bit.</p>
      <NuxtLink to="/quiz" class="btn-secondary mt-4">Back to quizzes</NuxtLink>
    </div>

    <div v-else-if="phase==='left'" class="card p-8 text-center">
      <p class="font-bold">Your opponent left the match.</p>
      <NuxtLink to="/quiz" class="btn-primary mt-4">Find another game</NuxtLink>
    </div>

    <!-- Playing -->
    <div v-else-if="phase==='playing' && current">
      <div class="card px-4 py-3 mb-6 flex items-center justify-between">
        <div class="text-center">
          <p class="text-xs font-bold text-cocoa-500 truncate max-w-[8rem]">You</p>
          <p class="font-display text-2xl font-bold">{{myScore}}</p>
        </div>
        <p class="font-display font-bold text-cocoa-400">VS</p>
        <div class="text-center">
          <p class="text-xs font-bold text-cocoa-500 truncate max-w-[8rem]">{{opponent?.name||'Opponent'}}</p>
          <p class="font-display text-2xl font-bold">{{theirScore}}</p>
        </div>
      </div>

      <QuestionCard
          v-model="myAnswers[count]"
          :question="current"
          :number="count+1"
          :total="total"
          :revealed="revealed||lockedIn"
      />

      <div class="mt-6 flex items-center justify-between gap-4">
        <p class="font-bold text-cocoa-500">
          <template v-if="revealed">
            {{opponent?.name||'Opponent'}} {{results[count]?.[opponent?.id]?'got it right':'got it wrong'}}
          </template>
          <template v-else-if="lockedIn">Waiting for {{opponent?.name||'your opponent'}}…</template>
          <template v-else-if="opponentLockedIn">{{opponent?.name||'Your opponent'}} has answered!</template>
        </p>
        <button v-if="!lockedIn" class="btn-primary !px-8" :disabled="!myAnswers[count]" @click="lockIn">Lock in</button>
      </div>
    </div>

    <!-- Finished -->
    <div v-else-if="phase==='finished'" class="card p-8 text-center">
      <img src="/rabbit.png" alt="" class="h-28 w-28 mx-auto">
      <h1 class="text-4xl font-bold mt-2">
        {{myScore>theirScore?'You won!':myScore<theirScore?'You lost':'It\'s a draw'}}
      </h1>
      <p class="text-cocoa-500 mt-1">{{quiz?.name}}</p>

      <div class="grid grid-cols-2 gap-3 my-6 max-w-sm mx-auto">
        <div class="rounded-2xl p-4" :class="myScore>=theirScore?'bg-amber-100':'bg-cocoa-50'">
          <p class="text-xs font-bold uppercase tracking-wide text-cocoa-500">You</p>
          <p class="font-display text-3xl font-bold">{{myScore}}/{{total}}</p>
        </div>
        <div class="rounded-2xl p-4" :class="theirScore>=myScore?'bg-amber-100':'bg-cocoa-50'">
          <p class="text-xs font-bold uppercase tracking-wide text-cocoa-500 truncate">{{opponent?.name||'Opponent'}}</p>
          <p class="font-display text-3xl font-bold">{{theirScore}}/{{total}}</p>
        </div>
      </div>
      <p class="font-bold">+{{myScore*10}} points</p>

      <div class="flex flex-wrap justify-center gap-3 mt-6">
        <NuxtLink to="/home" class="btn-secondary">Back to home</NuxtLink>
        <NuxtLink to="/quiz" class="btn-primary">Play again</NuxtLink>
      </div>
    </div>
  </div>
</template>
