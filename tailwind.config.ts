import type {Config} from 'tailwindcss'
import defaultTheme from 'tailwindcss/defaultTheme'

export default <Partial<Config>>{
  theme:{
    extend:{
      fontFamily:{
        sans:['Nunito',...defaultTheme.fontFamily.sans],
        display:['Fredoka',...defaultTheme.fontFamily.sans]
      },
      colors:{
        // warm palette taken from the rabbit mascot
        cream:'#fffaf0',
        cocoa:{
          50:'#faf5f0',
          100:'#f0e4d8',
          200:'#e0c9b3',
          400:'#a8805e',
          500:'#8a6244',
          700:'#5c3a22',
          900:'#3b2414'
        }
      }
    }
  }
}
