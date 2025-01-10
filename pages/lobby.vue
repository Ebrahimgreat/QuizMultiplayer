<script setup lang="ts">

import { ref } from 'vue';

import {SupabaseClient} from "@supabase/supabase-js";

import{usequizStore} from "~/stores/quizStart";
const quizStore=usequizStore();
import{useRoleStore} from "~/stores/role";


const roleStore=useRoleStore();
let userName=roleStore.name
let userId=roleStore.id

let users=ref([])
let count=ref(0)

let userAnswer=ref([])

let quizName=ref('')
let questions=ref([])
let answers=ref([])
let options=ref([])
let quizData=ref([])
let quizFetched=ref(false)

let winnerName=ref()
let winnerId=ref()


async function getcurrentUser() {
  const supabase = useSupabaseClient();

  const user = supabase.auth.getUser();


}



let profiles=ref([])
async function joinLobby()
{
  const supabase = useSupabaseClient();
  const user = await supabase.auth.getUser();


  if (!user.data.user) {
    console.error('User not authenticated');
    return;
  }



  const userId = user.data.user.id;




  try {
    const {
      data: profileData,
      error: profileError
    } = await supabase.from('profiles').select('*').eq('user_id', userId).single();

    profiles.value = profileData
    const {data: profileValues, error: errorProfile} = await supabase.from('lobby').insert({
      user_profile_id: profileData.id,
      lobby_name: 'ebrahimLobby'

    });



  }
  catch (error){
  console.log(error)}
}


const disabled=ref(false)
function warnDisabled(){
  disabled.value=true;
  setTimeout(()=>{
    disabled.value=false
  },1500)
}


let nextButton=ref(false)


let gameStart=ref(false)

let moveNext=ref([])

let winner=ref([])

let results=ref([])

let status=ref('')

let challengeId=ref()
async function subscribeToLobby() {
  const supabase = useSupabaseClient();

  supabase.channel('ebrahimLobby').on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'lobby',
  }, async (payload) => {
    console.log(payload)

    if (!users.value.some((user) => user.user_profile_id === payload.new.user_profile_id)) {
      users.value.push(payload.new);

    }
    if(users.value.length==1){
      const{data:challengeResult,error}=await  supabase.from('challenge').insert({
        challenger_id:payload.new.user_profile_id,
      }).select('id').single()
      challengeId.value=challengeResult;

    }
    if(users.value.length==2){
      const{data,error}=await  supabase.from('challenge').update({
        reciever_id:payload.new.user_profile_id,
      }).eq('id',challengeId.value.id)
    }

    if (users.value.length === 2 && !quizFetched.value) {
      quizFetched.value = true;
      gameStart.value = true;
      nextButton.value = false
      await getQuizData();

    }
  }).subscribe();

  if(gameStart.value && nextButton.value) {
  }

  supabase.channel('ebrahimLobby').on('broadcast', { event: 'next' }, (eventPayload) => {
    const userId = eventPayload.payload.id;
    if (!moveNext.value.includes(userId)) {


      moveNext.value.push(userId);
    }
    if (moveNext.value.length === 2) {
      count.value++;
      nextButton.value = false;
      moveNext.value = [];
    }
  });


  supabase.channel('ebrahimLobby').on('broadcast',{event:'submit'},async (eventPayload) => {


    const {profile, correct} = eventPayload.payload;
    if (!results.value.includes(profile)) {
      results.value.push({profile, correct})
    }


    if (results.value.length == 2) {
      let correctAnswer = 0
      let player = '';

       winnerId.value=results.value[0]?.profile;



      results.value.forEach((item) => {
        if (results.value[1]?.correct > correctAnswer) {
          correctAnswer = results.value[1]?.correct;
          winnerId.value = results.value[1].profile


        }
      });



      const{data:statsTable,error:statsValueError}=await supabase.rpc('update_stats',{
        profile_id:results.value[0].profile,
        points_to_add:(results.value[0].correct)*10,
        games_to_add:1

      })
      const{data:statsTable1,error:statsValurError1}=await supabase.rpc('update_stats',{
        profile_id:results.value[1].profile,
        points_to_add:(results.value[1].correct)*10,
        games_to_add:1

      })

      const {data: quizScoreUpdate, error: quizScoreError} = await supabase.from('challenge').update({
          challenger_score: results.value[0]?.correct,
          challenge_recieverScore: results.value[1]?.correct,
          winner: winnerId.value

        }).eq('id', challengeId.value.id);
        if (quizScoreError) {
          console.log(quizScoreError)
        }


        quizComplete.value = true;


      }



  })

}


async function getQuizData() {
  let supabase = useSupabaseClient();
  const url = new URLSearchParams(window.location.search);
   let quizId = url.get('id');

  try {
    const supabase = useSupabaseClient();
    const {data: quizValue, error: quizError} = await supabase.from('quiz').select('name').eq('id', quizId).single();

    if (quizError) {
      console.log(quizError);
      return;
    }
    quizName.value = quizValue.name

    let {data:quizInformation, error:questionError} =await supabase.from('quiz_question').select('id,question').eq('quiz_id',quizId)
    if(questionError)
    {
      console.log(questionError);
      return;
    }

    questions.value=quizInformation?.map((item)=>({
      question:item.question
    }));

    const{data:answerData,error:answerError}= await supabase.from('quiz_answer').select('answer').in('question_id',quizInformation.map((item)=>item.id));
    if(answerError){
    }
    answers.value=answerData.map((item)=>({
      answer:item.answer
    }));

    const{data:optionData,error:optionError}=await supabase.from('quiz_options').select('A,B,C,D').in('quiz_questions',quizInformation?.map((item)=>item.id))
    if(optionError)
    {
      return;
    }
    options.value=optionData.map((item)=>({
      A:item.A,
      B:item.B,
      C:item.C,
      D:item.D
    }))
    await quizStore.setData(quizName.value, questions.value, options.value,answers.value)


    let quizQuestions=quizStore.questions;
    let quizOptions=quizStore.options;
    quizData.value=quizStore.questions.map((item,index)=>({
      question:item.question,
      option:quizStore.options[index]
    }))

  }

  catch (error) {
    console.log(error);
  }
}
let correct=ref(0)
async function submitQuiz()
{
  let answers=quizStore.answers;
  for(let i=0; i<userAnswer.value.length; i++)
  {

    if(userAnswer.value[i]==answers[i].answer)
    {

      correct.value++;

    }


  }

  const supabase=useSupabaseClient()

  let profile=roleStore.id
  const channel=supabase.channel('ebrahimLobby');
  await channel.send({
    type:'broadcast',
    event:'submit',
    payload:{profile,correct:correct.value}
  })



}
async function next() {

console.log(profiles.value.id)
let supabase=useSupabaseClient()
  const channel=supabase.channel('ebrahimLobby');
  await channel.send({
    type:'broadcast',
    event:'next',
    payload:{id:profiles.value.id}


  })




}


let quizComplete=ref(false)


onMounted(()=>{
  subscribeToLobby()
})



</script>

<template>







  <button @click="joinLobby">
    Join Lobby
  </button>


  <div class="bg-gray-900 h-screen w-full p-6 text-white">
    <div v-if="!quizComplete">

      <h1 class="text-white text-center">
        Quiz Selected:
        {{quizName}}


      </h1>



      <div v-if="quizData.length>0">



        Game Starting

        {{userAnswer[count]}}


        <div class="bg-white p-5">

          <h1 class="text-center text-black">
            {{quizData[count].question}}
          </h1>




          <div  class="bg-gray-400 p-3 rounded-lg mb-3">

            <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
              <input type="radio" name="questionAnswer" :value="quizData[count].option.A" v-model="userAnswer[count]"> A
            </div>

            <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
              {{quizData[count].option.A}}



            </div>



          </div>
          {{userAnswer[count]}}
          <div  class="bg-gray-400 p-3 rounded-lg mb-3">

            <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
              <input type="radio" name="questionAnswer" :value="quizData[count].option.B" v-model="userAnswer[count]"> B
            </div>

            <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
              {{quizData[count].option.B}}

            </div>



          </div>
          <div  class="bg-gray-400 p-3 rounded-lg mb-3">

            <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
              <input type="radio" name="questionAnswer" :value="quizData[count].option.C"  v-model="userAnswer[count]"> C
            </div>

            <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
              {{quizData[count].option.C}}

            </div>



          </div>
          <div  class="bg-gray-400 p-3 rounded-lg mb-3">

            <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
              <input type="radio" name="questionAnswer" :value="quizData[count].option.D"  v-model="userAnswer[count]"> D
            </div>

            <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
              {{quizData[count].option.D}}




            </div>



          </div>


          {{count}}
          <button @click="next">
            <h2 class="text-center text-black" >Next</h2>
          </button>
          <div v-if="count==questions.length-1">
            <button @click="submitQuiz">
              <h4 class="text-black"> Submit</h4>
            </button>
          </div>




        </div>







      </div>
    </div>



    <div v-if="quizComplete==true">


      <h1 class="text-center text-white text-4xl"> Quiz Rabbit:</h1>


      <h2 class="text-white"> Results Summary</h2>
      <h3 class="text-white">
        Quiz Name:{{quizName}}
      </h3>


      <ul>
        <li v-for="result in results">
          User :{{result.userId}},  correct Answers: {{result.correct}}
        </li>
      </ul>
      <div v-if="winnerId==userId">
        You are winner

    </div>
      <div v-else>
        You are a looser
      </div>

  </div>


</div>





</template>

<style scoped>

.shake {
  animation: shake 0.82s cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
  transform: translate3d(0, 0, 0);
}

@keyframes shake {
  10%,
  90% {
    transform: translate3d(-1px, 0, 0);
  }

  20%,
  80% {
    transform: translate3d(2px, 0, 0);
  }

  30%,
  50%,
  70% {
    transform: translate3d(-4px, 0, 0);
  }

  40%,
  60% {
    transform: translate3d(4px, 0, 0);
  }
}

</style>
