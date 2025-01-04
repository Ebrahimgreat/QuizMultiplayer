console.log('Nuxt Config Loaded');
export default defineNuxtConfig({
  compatibilityDate: '2024-12-28',
  supabase:{
    redirect:false
  },
  router:{
    middleware:"auth"
  },

  modules:[
    '@nuxtjs/supabase',
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
  ]
});