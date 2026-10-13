<script setup lang="ts">
import{QUIZ_CATEGORIES,OPTION_KEYS} from "~/composables/useQuiz";

function blankQuestion()
{
  return{question:'',options:{A:'',B:'',C:'',D:''},correct:'A'};
}

const quizName=ref('');
const selected=ref<number|null>(null);
const questions=ref([blankQuestion()]);
const errorMessage=ref('');
const saving=ref(false);
const created=ref(false);

function addQuestion()
{
  questions.value.push(blankQuestion());
}

function removeQuestion(index)
{
  questions.value.splice(index,1);
}

function validate()
{
  if(!quizName.value.trim()) return 'Give your quiz a name.';
  if(selected.value==null) return 'Choose a category.';
  if(questions.value.length===0) return 'Add at least one question.';
  for(const [i,q] of questions.value.entries())
  {
    if(!q.question.trim()) return `Question ${i+1} is empty.`;
    if(OPTION_KEYS.some((k)=>!q.options[k].trim())) return `Fill in all four options for question ${i+1}.`;
  }
  return '';
}

async function createQuiz()
{
  errorMessage.value=validate();
  if(errorMessage.value) return;

  saving.value=true;
  const supabase=useSupabaseClient();
  const user=useSupabaseUser();
  try {
    const {data: quizData, error: quizError} = await supabase.from('quiz').insert({
      name: quizName.value.trim(),
      quiz_category: selected.value+1,
      users_id: user.value?.id
    }).select('id').single();
    if (quizError) throw quizError;

    const {data: questionInsertData, error: questionError} = await supabase.from('quiz_question').insert(
        questions.value.map((q)=>({quiz_id:quizData.id,question:q.question.trim()}))
    ).select('id');
    if (questionError) throw questionError;
    // ids are generated in insert order, so sorting lines them up with questions.value
    questionInsertData.sort((a,b)=>a.id-b.id);

    // the answer is stored as the text of the correct option
    const{error:answerError}=await supabase.from('quiz_answer').insert(
        questionInsertData.map((item,index)=>({
          question_id:item.id,
          answer:questions.value[index].options[questions.value[index].correct].trim()
        }))
    );
    if(answerError) throw answerError;

    const{error:optionError}=await supabase.from('quiz_options').insert(
        questionInsertData.map((item,index)=>{
          const o=questions.value[index].options;
          return{quiz_questions:item.id,A:o.A.trim(),B:o.B.trim(),C:o.C.trim(),D:o.D.trim()};
        })
    );
    if(optionError) throw optionError;

    created.value=true;
  }
  catch (error)
  {
    console.log(error);
    errorMessage.value='Something went wrong saving your quiz. Please try again.';
  }
  saving.value=false;
}

function startOver()
{
  quizName.value='';
  selected.value=null;
  questions.value=[blankQuestion()];
  created.value=false;
}

const optionColors={A:'bg-rose-500',B:'bg-sky-500',C:'bg-amber-500',D:'bg-emerald-500'};
</script>

<template>
  <div class="page max-w-3xl">
    <div v-if="created" class="card p-8 text-center">
      <img src="/rabbit.png" alt="" class="h-24 w-24 mx-auto">
      <h1 class="text-3xl font-bold mt-3">Quiz published!</h1>
      <p class="text-cocoa-500 mt-1"><b>{{quizName}}</b> is now live for players.</p>
      <div class="flex flex-wrap justify-center gap-3 mt-6">
        <NuxtLink to="/home" class="btn-secondary">Back to dashboard</NuxtLink>
        <button class="btn-primary" @click="startOver">Create another</button>
      </div>
    </div>

    <form v-else @submit.prevent="createQuiz">
      <h1 class="page-title">New quiz</h1>
      <p class="text-cocoa-500 mt-1 mb-6">Write your questions and mark the right answer for each one.</p>

      <div class="card p-5 sm:p-6 space-y-5 mb-6">
        <div>
          <label class="label" for="quiz-name">Quiz name</label>
          <input id="quiz-name" v-model="quizName" type="text" class="input" placeholder="e.g. World capitals">
        </div>
        <div>
          <p class="label">Category</p>
          <div class="flex flex-wrap gap-2">
            <button
                v-for="(item,index) in QUIZ_CATEGORIES"
                :key="item"
                type="button"
                class="px-4 py-2 rounded-full font-bold border-2 transition"
                :class="selected===index?'bg-cocoa-900 border-cocoa-900 text-white':'bg-white border-cocoa-100 text-cocoa-700 hover:border-cocoa-200'"
                @click="selected=index"
            >
              {{item}}
            </button>
          </div>
        </div>
      </div>

      <div class="space-y-4">
        <div v-for="(item,index) in questions" :key="index" class="card p-5 sm:p-6">
          <div class="flex items-center justify-between mb-3">
            <h2 class="text-lg font-bold">Question {{index+1}}</h2>
            <button
                v-if="questions.length>1"
                type="button"
                class="text-sm font-bold text-red-600 hover:underline"
                @click="removeQuestion(index)"
            >
              Remove
            </button>
          </div>

          <input v-model="item.question" type="text" class="input mb-4" placeholder="Type your question">

          <p class="text-sm text-cocoa-500 mb-2">Fill in the options and tick the correct one.</p>
          <div class="grid sm:grid-cols-2 gap-3">
            <label
                v-for="key in OPTION_KEYS"
                :key="key"
                class="flex items-center gap-2 rounded-xl border-2 p-1.5 pr-3 transition"
                :class="item.correct===key?'border-emerald-400 bg-emerald-50':'border-cocoa-100'"
            >
              <span class="h-9 w-9 shrink-0 rounded-lg grid place-items-center font-display font-bold text-white" :class="optionColors[key]">{{key}}</span>
              <input v-model="item.options[key]" type="text" class="flex-1 min-w-0 bg-transparent py-1.5 focus:outline-none" :placeholder="`Option ${key}`">
              <input v-model="item.correct" type="radio" :name="`correct-${index}`" :value="key" class="h-5 w-5 accent-emerald-600" :aria-label="`Option ${key} is correct`">
            </label>
          </div>
        </div>
      </div>

      <button type="button" class="btn-secondary w-full mt-4 border-dashed !border-2" @click="addQuestion">
        + Add question
      </button>

      <div class="sticky bottom-0 mt-6 -mx-4 sm:mx-0 px-4 py-4 bg-cream/95 backdrop-blur border-t border-cocoa-100 sm:border-0 flex flex-wrap items-center justify-between gap-3">
        <p class="text-cocoa-500 font-bold">{{questions.length}} question{{questions.length===1?'':'s'}}</p>
        <p v-if="errorMessage" class="text-sm text-red-700 order-last w-full sm:order-none sm:w-auto">{{errorMessage}}</p>
        <button type="submit" class="btn-primary" :disabled="saving">{{saving?'Publishing…':'Publish quiz'}}</button>
      </div>
    </form>
  </div>
</template>
