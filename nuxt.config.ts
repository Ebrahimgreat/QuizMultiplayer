export default defineNuxtConfig({
  compatibilityDate: '2024-12-28',
  supabase:{
    redirect:false
  },

  app:{
    head:{
      title:'Quiz Rabbit',
      meta:[
        {name:'viewport',content:'width=device-width, initial-scale=1'}
      ],
      link:[
        {rel:'icon',type:'image/png',href:'/rabbit.png'},
        {rel:'preconnect',href:'https://fonts.googleapis.com'},
        {rel:'preconnect',href:'https://fonts.gstatic.com',crossorigin:''},
        {rel:'stylesheet',href:'https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;600;700;800&display=swap'}
      ]
    }
  },

  modules:[
    '@nuxtjs/supabase',
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
  ]
});
