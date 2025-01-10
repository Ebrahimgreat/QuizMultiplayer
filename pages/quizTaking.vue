<script setup lang="ts" xmlns="http://www.w3.org/1999/html">



import {SupabaseClient} from "@supabase/supabase-js";

const colors=['none','none','none','none']
import{usequizStore} from "~/stores/quizStart";


import {ca} from "cronstrue/dist/i18n/locales/ca";
import {useRoleStore} from "#imports";
const quizStore=usequizStore();
const roleStore=useRoleStore();
let questions=quizStore.questions;
let options=quizStore.options;
let quizAnswers=quizStore.answers
let challenge=quizStore.challengeId
const quizData=questions.map((item,index)=>({
  question:item.question,
      option:options[index]
}));
let profile=ref('')

let startChallenge=ref(false)
let receiveChallenge=ref(false);
async function quizIntialize()
{
  const url = new URLSearchParams(window.location.search);

  startChallenge.value=url.get('startChallenge')
  receiveChallenge.value=url.get('recieveChallenge');
}


let count=ref(0)
function next()
{
  if(count.value>=quizData.length-1)
  {
    alert("Quiz Has been completed, click summary to view the results");
  }
  count.value++;
}

let correct=0;
let score=ref(0);

async function checkAnswer()
{
  if(answers.value[count.value]==quizAnswers[count.value].answer)
  {
   alert('Correct Answer')
    score.value+=10;
  }
  else{
    alert('Sorry Your answer was wrong')
  }
  count.value++;

}

async function start()
{
  const url = new URLSearchParams(window.location.search);


  startChallenge.value=url.get('startChallenge');
}
async function quizComplete()
{
  profile.value=roleStore.id

 for(let i=0; i<quizAnswers.length; i++)
 {
   if(answers.value[i]==quizAnswers[i].answer)
   {
     correct++;

   }
 }
 score.value=(correct/questions.length)*100;


  submitQuiz.value=true;

  let supabase=useSupabaseClient();



  let currentUser=useSupabaseUser();
  try {


console.log("Score")
    if (startChallenge.value) {
      console.log('challenge',challenge)
      const {data: challengeData,error:challengeDataError} = await supabase.from('challenge').update({
        challenger_score: score.value
      }).eq('id', challenge);
      if(challengeDataError){
        console.log(challengeDataError)
      }

    }
    else if(receiveChallenge.value){
      console.log('Recieving challenge');
      const{data:challengeScore,error:challengeDataError}=await supabase.from('challenge').update({
        recieverScore:score.value,
      }).eq('id',challenge).select('challengerScore')
      let winner=ref('')
      if(score.value>challengeScore)
      {
        winner.value='reciever'
      }
      else{
        winner.value='challenger'
      }



    }



    const{data:statsTable,error:statsValueError}=await supabase.rpc('update_stats',{
      profile_id:profile.value,
      points_to_add:score.value,
      games_to_add:1

    })


    if(statsValueError){
      console.log(statsValueError)
    }




  }
  catch(error){
    console.log(error);
  }






}


function previous()
{
  count.value--;
}

let answer=ref();
let answers=ref([]);


let submitQuiz=ref(false)
onMounted(()=>{
  quizIntialize()


})
</script>

<template>
  <div
      class="bg-gray-900 min-h-screen w-full p-6 text-white flex flex-col items-center justify-center overflow-auto"
  >
    <div v-if="submitQuiz == false" class="w-[75%]">
      <div class="bg-white shadow-lg rounded-lg p-6 w-full overflow-y-auto">
        <h1 class="text-3xl text-center mb-4">
          Challenge {{ startChallenge }}
        </h1>
        <div class="rounded-lg bg-gray-100 p-2 mb-4">
          {{ answers.length }}
        </div>

        <div class="bg-white p-5 rounded-lg shadow-lg">
          <div class="text-center text-2xl mb-4">
            Question {{ count + 1 }}/{{ quizData.length }}
          </div>

          <div class="text-center mb-6">
            <div class="bg-gray-100 rounded-lg inline-block px-8 py-3">
              <p class="text-gray-700 text-lg font-medium">Current Score</p>
              <p class="text-4xl font-bold text-purple-950">{{ score }}</p>
            </div>
          </div>

          <h1
              class="text-center text-4xl text-purple-950 font-bold mb-6 p-4 bg-gray-100 rounded-lg"
          >
            {{ quizData[count].question }}
          </h1>

          <div class="bg-gray-400 p-3 rounded-lg mb-3">
            <div class="bg-red-600 rounded-lg font-bold p-2 flex w-12">
              <input
                  type="radio"
                  name="questionAnswer"
                  :value="quizData[count].option.A"
                  v-model="answers[count]"
              />
              A
            </div>
            <div
                class="flex items-center justify-center hover:bg-red-500 font-bold text-gray-800 mt-4 p-2 rounded-lg transition duration-300"
            >
              {{ quizData[count].option.A }}
            </div>
          </div>

          <div class="bg-gray-400 p-3 rounded-lg mb-3">
            <div class="bg-red-600 rounded-lg font-bold p-2 flex w-12">
              <input
                  type="radio"
                  name="questionAnswer"
                  :value="quizData[count].option.B"
                  v-model="answers[count]"
              />
              B
            </div>
            <div
                class="flex items-center justify-center hover:bg-red-500 font-bold text-gray-800 mt-4 p-2 rounded-lg transition duration-300"
            >
              {{ quizData[count].option.B }}
            </div>
          </div>

          <div class="bg-gray-400 p-3 rounded-lg mb-3">
            <div class="bg-red-600 rounded-lg font-bold p-2 flex w-12">
              <input
                  type="radio"
                  name="questionAnswer"
                  :value="quizData[count].option.C"
                  v-model="answers[count]"
              />
              C
            </div>
            <div
                class="flex items-center justify-center hover:bg-red-500 font-bold text-gray-800 mt-4 p-2 rounded-lg transition duration-300"
            >
              {{ quizData[count].option.C }}
            </div>
          </div>

          <div class="bg-gray-400 p-3 rounded-lg mb-3">
            <div class="bg-red-600 rounded-lg font-bold p-2 flex w-12">
              <input
                  type="radio"
                  name="questionAnswer"
                  :value="quizData[count].option.D"
                  v-model="answers[count]"
              />
              D
            </div>
            <div
                class="flex items-center justify-center hover:bg-red-500 font-bold text-gray-800 mt-4 p-2 rounded-lg transition duration-300"
            >
              {{ quizData[count].option.D }}
            </div>
          </div>

          <div
              v-if="count >= quizData.length - 1"
              class="flex items-center justify-center mt-6"
          >
            <button
                @click="quizComplete"
                class="bg-green-500 text-white p-2 rounded hover:bg-green-600 transition duration-300"
            >
              Submit Quiz
            </button>
          </div>

          <div class="flex items-center justify-center mt-6">
            <button
                @click="checkAnswer"
                class="bg-blue-500 text-white p-2 rounded hover:bg-blue-600 transition duration-300"
            >
              Next
            </button>
          </div>

          <div class="mt-8 text-center">
            <div class="h-1 w-12 bg-gray-800 rounded-full mx-auto">
              <p class="font-bold text-gray-800">
                {{ count + 1 }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else>
      <div
          class="bg-gray-900 h-screen flex flex-col items-center justify-center p-6"
      >
        <h1 class="text-center text-5xl mb-3">Your Results</h1>
        <h2 class="text-center text-2xl mb-2">
          Attempted: {{ answers.length }}
        </h2>
        <h3 class="text-center text-2xl mb-2">Correct: {{ correct }}</h3>
        <h4 class="text-center text-2xl mb-2">Score: {{ score }}</h4>
        <h5 class="text-center text-2xl mb-2">
          <NuxtLink
              to="/home"
              class="text-blue-500 hover:text-blue-700 transition duration-300"
          >
            Back To Home
          </NuxtLink>
        </h5>
      </div>
    </div>
  </div>
</template>





<style scoped>

</style>