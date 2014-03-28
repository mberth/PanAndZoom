require.config({
  paths: {
    'paper': '../../bower_components/paper/dist/paper'
  }
})

require ['demo_03'], (example) ->
  example('paper1')
