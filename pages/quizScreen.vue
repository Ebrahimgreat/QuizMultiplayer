<script setup lang="ts">
import{usequizStore} from "~/stores/quizStart";
const quizStore=usequizStore();
let options=ref([
])
let questions=ref([
])

let answers=ref([])

let quizName=ref()

async function getQuizData() {
  const url = new URLSearchParams(window.location.search);
  let quizId = url.get('id');

  try {
    const supabase = useSupabaseClient();
    const {data: quizValue, error: quizError} = await supabase.from('quiz').select('name').eq('id', quizId).single();

    if (quizError) {
      console.log(quizError);
      return;
    }
    quizName.value=quizValue.name;
    const {data:quizData, error:questionError} =await supabase.from('quiz_question').select('id,question').eq('quiz_id',quizId)
    if(questionError)
    {
      console.log(questionError);
      return;
    }
    console.log('questions fetched');



    questions.value=quizData?.map((item)=>({
      question:item.question
    }));

    const{data:answerData,error:answerError}= await supabase.from('quiz_answer').select('answer').in('question_id',quizData.map((item)=>item.id));
    if(answerError){
      console.log(answerError);
    }
    answers.value=answerData.map((item)=>({
      answer:item.answer
    }));

    const{data:optionData,error:optionError}=await supabase.from('quiz_options').select('A,B,C,D').in('quiz_questions',quizData?.map((item)=>item.id))
if(optionError)
{
  console.log(optionError);
  return;
}
console.log('options fetched')
options.value=optionData.map((item)=>({
  A:item.A,
  B:item.B,
  C:item.C,
  D:item.D
}))
    await quizStore.setData(quizName.value, questions.value, options.value,answers.value)

  }

  catch(error)
  {
    console.log(error);
  }
}
function startQuiz()
{
  navigateTo({
    path:'/quizTaking',
  })
}
onMounted(()=>{
  getQuizData()
})
</script>

<template>

<div class="bg-blue-900 h-screen flex flex-col items-center justify-center">

  <h1 class="text-center text-white text-5xl">
    Quiz Rabbit
  </h1>

  <h2 class="text-white"> Name:<b>{{quizName}}</b></h2>
  <h3 class="text-white"> Total Questions:{{questions.length}}
  </h3>

  <img src="/images/rabbit.png" class="w-auto h-1/2 object-contain">
  <button @click="startQuiz" class="bg-white hover:bg-gray-100 text-gray-800 font-semibold py-2 px-4 border border-gray-400 rounded shadow">
    Start Quiz
  </button>

</div>


</template>

<style scoped>

</style>