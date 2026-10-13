<script setup lang="ts">
import{OPTION_KEYS,isCorrect,type QuizQuestion} from "~/composables/useQuiz";

const props=defineProps<{
  question:QuizQuestion
  number:number
  total:number
  modelValue?:string
  revealed?:boolean
}>();
const emit=defineEmits<{'update:modelValue':[value:string]}>();

const optionColors={A:'bg-rose-500',B:'bg-sky-500',C:'bg-amber-500',D:'bg-emerald-500'};

function tileClass(key)
{
  const text=props.question.options[key];
  const picked=props.modelValue===text;
  if(props.revealed)
  {
    if(isCorrect(props.question,text)) return 'border-emerald-500 bg-emerald-50';
    if(picked) return 'border-red-400 bg-red-50';
    return 'border-cocoa-100 opacity-60';
  }
  return picked?'border-amber-400 bg-amber-50 ring-4 ring-amber-100':'border-cocoa-100 hover:border-cocoa-200 hover:-translate-y-0.5';
}

function pick(key)
{
  if(props.revealed) return;
  emit('update:modelValue',props.question.options[key]);
}
</script>

<template>
  <div>
    <div class="flex items-center gap-3 mb-3">
      <span class="text-sm font-bold text-cocoa-500 whitespace-nowrap">Question {{number}} of {{total}}</span>
      <div class="h-2 flex-1 rounded-full bg-cocoa-100 overflow-hidden">
        <div class="h-full bg-amber-400 transition-all duration-300" :style="{width:`${(number/total)*100}%`}" />
      </div>
    </div>

    <div class="card p-6 sm:p-8 mb-4">
      <h2 class="text-2xl sm:text-3xl font-bold text-center">{{question.question}}</h2>
    </div>

    <div class="grid sm:grid-cols-2 gap-3">
      <button
          v-for="key in OPTION_KEYS"
          :key="key"
          type="button"
          class="flex items-center gap-3 rounded-2xl border-2 bg-white p-3 text-left font-bold transition"
          :class="tileClass(key)"
          :disabled="revealed"
          @click="pick(key)"
      >
        <span class="h-10 w-10 shrink-0 rounded-xl grid place-items-center font-display text-lg text-white" :class="optionColors[key]">{{key}}</span>
        <span class="flex-1">{{question.options[key]}}</span>
        <span v-if="revealed && isCorrect(question,question.options[key])" class="text-emerald-600">✓</span>
        <span v-else-if="revealed && modelValue===question.options[key]" class="text-red-500">✗</span>
      </button>
    </div>
  </div>
</template>
