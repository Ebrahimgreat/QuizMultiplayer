<script setup lang="ts">


import {definePageMeta} from "#imports";
import {ca} from "cronstrue/dist/i18n/locales/ca";

definePageMeta({
  layouts:'default'
});
let items=['Math','Sports','Science','Journalling','Art','Travel']


let quizName=ref()
let questions=ref([
  {
    question: "How many calories are there in a gram of Fat?",


  },
  {
    question: "How many calories are there in a gram of protein?",
  },
  {
    question: "How many calories are there in a gram of carb?",

  }

]);
let answers=ref([
  {
    answer: '9',

  },
  {
    answer:'4'
  },
  {
    answer:'4'
  }
])
let options=ref([
  {
    option:
      {A:'9',B:'3',C:'7',D:'2'}

  },
  {
    option:
        {A:'9',B:'3',C:'7',D:'2'}

  },
  {
    option:
        {A:'9',B:'3',C:'7',D:'2'}

  }
])
function addQuestion()
{
  questions.value.push({
    question:""
  });
  options.value.push({
    option:
      {A:'',B:'',C:'',D:''}

  })
  answers.value.push({
    answer:""
  })

}
function removeQuestion(index)
{
  questions.value.splice(index,1);
}

let timed=ref(false)

let selected=ref()

let category=ref('')
function categorySelected(index,value)
{
  selected.value=index;
  category.value=value;


}


async function createQuiz()
{
  console.log('creating your quiz');

  let supabase=useSupabaseClient()
  try {
    const {data: quizData, error: quizError} = await supabase.from('quiz').insert({
      'name': quizName.value,
      'quiz_category':selected.value+1
    }).select('id').single();
    if (quizError) {
      console.log("Error creating a quiz")
      return;
    }
    const quizId = quizData.id;
    console.log('quiz Created');

    const questionData=questions.value.map((item)=>({
      quiz_id:quizId,
      question:item.question
    }));


    const {data: questionInsertData, error: questionError} = await supabase.from('quiz_question').insert(
     questionData
    ).select();
    if (questionError) {
      console.log(questionError)
      return;
    }
   console.log('question Inserted');
    const answerData=questionInsertData.map((item,index)=>({
      question_id:item.id,
      answer:answers.value[index].answer

    }));
    const{error:answerError}=await supabase.from('quiz_answer').insert(answerData)
    if(answerError){
      console.log(answerError);
      return;

    }
    console.log('answers inserted');
    const optionData = questionInsertData.map((question, index) => ({
      quiz_questions: question.id, // Link each option to its question ID
      A: options.value[index]?.option?.A || '',
      B: options.value[index]?.option?.B || '',
      C: options.value[index]?.option?.C || '',
      D: options.value[index]?.option?.D || '',
    }));
    const{error:optionError}=await supabase.from('quiz_options').insert(optionData)
    if(optionError)
    {
      console.log(optionError);
      return;
    }
    alert('Quiz Created successfullly...');




  }
  catch (error)
  {
  console.log(error)}
}


</script>

<template>



<div class="h-screen flex flex-col">

  <p class="text-center text-white bg-black">Creating  a New Quiz</p>
  <div class="bg-amber-600 p-4 border-2">
    <input type="text" v-model="quizName" placeholder="Enter quiz name" class="w-full py-2 border border-indigo-500 rounded mr-5">
   <h1 class="text-center text-white"> Choose a category
   </h1>
  <div class="grid grid-cols-4 gap-4 ">

   <button v-for="(item,index) in items" class="border p-4 text-center bg-grey-900"  v-bind:style="{backgroundColor:selected===index?'blue': 'white'}" @click="categorySelected(index,item)">
     {{item}}
   </button>
  </div>
  </div>

 <div class="bg-pink-800 border-t flex-1 overflow-y-auto p-4">
   <h1 class="text-white text-center">
     Number Of Questions:
     {{questions.length}}

   </h1>
  <button  @click="addQuestion" type="button" class="flex justify-start ml-2 rounded-md border px-3 py-2 bg-pink-600 text-black">
 Add
  </button>




<div v-for="(item,index) in questions" :key="index" class="mb-8">

    Q.{{index+1}}
  <div class="grid grid-cols-2 gap-4 mb-3">

    <input placeholder="Enter Your Question" v-model="item.question" class="w-full py-2 border border-indigo-500 rounded mr-5">

    <input v-model="answers[index].answer"  placeholder="Enter Your Answer" class="w-full py-2 border border-indigo-500 rounded mr-3.5">
  </div>
    <div class="grid grid-cols-2 gap-4">
    <input type="text" v-model="options[index].option.A"  placeholder="A" class=" py-2 border-border-indigo-500 rounded">
    <input type="text" v-model="options[index].option.B" placeholder="B" class=" py-2 border-border-indigo-500 rounded">
    <input type="text" v-model="options[index].option.C" placeholder="C" class=" py-2 border-border-indigo-500 rounded">
    <input type="text" v-model="options[index].option.D" placeholder="D"  class=" py-2 border-border-indigo-500 rounded">
    </div>

  <button @click="removeQuestion(index)" class="flex justify-start ml-2 rounded-md border px-3 py-2 bg-pink-600 text-white">
    Remove
  </button>
</div>



  <br>

 </div>
  <div class="bg-gray-400 p-4 flex-1">
    <div class="mb-4">

    <input class="mr-2" v-model="timed" type="radio" name="timer" value="true">
    Set Timer
    <input class="mr-2" type="radio" v-model="timed" name="timer" value="false">
    No Timer
    </div>
    <div v-if="timed==='true'" class="space-y-4">
<input type="number" placeholder="seconds" class="w-full py-2 px-3 border border-indigo-500 rounded">

      <input  type="number" placeholder="minutes" class="w-full py-2 px-4 border border-indigo-500 rounded">


    </div>



    <div class="flex flex-col items-center">
    <button @click="createQuiz" class="bg-blue-50">
      Create
    </button>
    </div>


    </div>




</div>



</template>

<style scoped>

</style>