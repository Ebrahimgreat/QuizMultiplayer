<script setup lang="ts">
import{fetchQuiz,type LoadedQuiz} from "~/composables/useQuiz";

const route=useRoute();
const supabase=useSupabaseClient();
const quiz=ref<LoadedQuiz|null>(null);
const errorMessage=ref('');
const isChallenge=computed(()=>!!route.query.challenge);

onMounted(async ()=>{
  try{
    quiz.value=await fetchQuiz(route.query.id as string,supabase);
  }
  catch(error)
  {
    console.log(error);
    errorMessage.value=`We couldn't load this quiz. ${error?.message??''}`;
  }
});

function startQuiz()
{
  navigateTo({path:'/quizTaking',query:route.query});
}
</script>

<template>
  <div class="flex-1 flex items-center justify-center px-4 py-10">
    <div class="card w-full max-w-md p-8 text-center">
      <img src="/rabbit.png" alt="Quiz Rabbit mascot" class="h-32 w-32 mx-auto">

      <template v-if="quiz">
        <span class="pill mt-4" :class="isChallenge?'bg-rose-100 text-rose-700':'bg-amber-100 text-amber-800'">
          {{isChallenge?'Challenge':'Solo'}}
        </span>
        <h1 class="text-3xl font-bold mt-2">{{quiz.name}}</h1>
        <p class="text-cocoa-500 mt-1">{{quiz.questions.length}} questions · 10 points for each right answer</p>
        <button class="btn-primary w-full mt-6 !py-3.5 text-lg" :disabled="quiz.questions.length===0" @click="startQuiz">
          Start quiz
        </button>
      </template>

      <p v-else-if="errorMessage" class="text-red-700 mt-4">{{errorMessage}}</p>
      <p v-else class="text-cocoa-500 mt-4">Loading quiz…</p>

      <NuxtLink to="/quiz" class="inline-block mt-4 text-sm font-bold text-cocoa-500 hover:text-cocoa-900">← Back to quizzes</NuxtLink>
    </div>
  </div>
</template>
