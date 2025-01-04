<script setup lang="ts" xmlns="http://www.w3.org/1999/html">



const colors=['none','none','none','none']
import{usequizStore} from "~/stores/quizStart";
const quizStore=usequizStore();
let questions=quizStore.questions;
let options=quizStore.options;
let quizAnswers=quizStore.answers
const quizData=questions.map((item,index)=>({
  question:item.question,
      option:options[index]
}));









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
let score=0;
function quizComplete()
{

 for(let i=0; i<quizAnswers.length; i++)
 {
   if(answers.value[i]==quizAnswers[i].answer)
   {
     correct++;

   }
 }
 score=(correct/questions.length)*100;


  submitQuiz.value=true;


}


function previous()
{
  count.value--;
}
let answer=ref();
let answers=ref([]);


let submitQuiz=ref(false)
</script>

<template>


  <div v-if="submitQuiz==false">
<div class="bg-white container shadow-lg rounded-lg">


  <div  class="rounded-lg bg-gray-100 p-2">

    {{answers.length}}
<div>


   <div class="bg-white p-5">


   <h1 class="text-center">
   {{quizData[count].question}}
   </h1>

   </div>

      <div  class="bg-gray-400 p-3 rounded-lg mb-3">

   <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
<input type="radio" name="questionAnswer" :value="quizData[count].option.A" v-model="answers[count]"> A
   </div>

    <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
      {{quizData[count].option.A}}



    </div>



  </div>
  <div  class="bg-gray-400 p-3 rounded-lg mb-3">

    <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
      <input type="radio" name="questionAnswer" :value="quizData[count].option.B" v-model="answers[count]"> B
    </div>

    <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
      {{quizData[count].option.B}}

    </div>



  </div>
  <div  class="bg-gray-400 p-3 rounded-lg mb-3">

    <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
      <input type="radio" name="questionAnswer" :value="quizData[count].option.C"  v-model="answers[count]"> C
    </div>

    <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
    {{quizData[count].option.C}}

    </div>



  </div>
  <div  class="bg-gray-400 p-3 rounded-lg mb-3">

    <div class="bg-red-600 rounded -lg font-bold p-2 flex w-12">
      <input type="radio" name="questionAnswer" :value="quizData[count].option.C"  v-model="answers[count]"> D
    </div>

    <div class="flex items justify-center hover:bg-red font-bold text-gray-800 mt-4">
    {{quizData[count].option.D}}




    </div>



  </div>

  <div v-if="count>=quizData.length-1" class="items-center">
    <button @click="quizComplete"> Submit Quiz</button>
  </div>



  <div class="flex items justify-center">
    <button @click="previous" class="mr-3.5">
      Previous
    </button>
    <button @click="next">
      Next
    </button>
  </div>


<div class="mt-8 text-center" >
  <div class="h-1 w-12 bg-gray-800 rounded-full mx-auto">
    <p class="font-bold text-gray-800">
    {{count+1}}
    </p>
  </div>
</div>
</div>
  </div>
</div>
  </div>
  <div v-else>
    <div class="bg-blue-900 h-screen">
      <h1 class=" text-center text-white text-5xl mb-3" >Your Results</h1>
      <h2 class="text-center text-white"> Attempted:{{answers.length}}</h2>
      <h3 class="text-center text-white"> Correct:{{correct}} </h3>
      <h4 class="text-center text-white"> Score:{{score}}</h4>

    </div>
  </div>


</template>

<style scoped>

</style>