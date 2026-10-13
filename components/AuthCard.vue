<script setup lang="ts">
defineProps<{title:string,subtitle?:string}>()
</script>

<template>
  <div class="flex-1 flex items-center justify-center px-4 py-10">
    <div class="w-full max-w-md">
      <div class="flex flex-col items-center mb-6">
        <img src="/rabbit.png" alt="Quiz Rabbit mascot" class="h-24 w-24 drop-shadow">
        <h1 class="mt-2 text-4xl font-bold">Quiz Rabbit</h1>
      </div>
      <div class="card p-6 sm:p-8">
        <h2 class="text-2xl font-bold">{{title}}</h2>
        <p v-if="subtitle" class="text-cocoa-500 mt-1 mb-6">{{subtitle}}</p>
        <slot />
      </div>
      <div class="mt-5 text-center text-cocoa-500">
        <slot name="footer" />
      </div>
    </div>
  </div>
</template>
