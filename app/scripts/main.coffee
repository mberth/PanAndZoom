require.config({
  paths: {
    'jquery': '../bower_components/jquery/jquery',
    'jquery-mousewheel': '../../bower_components/jquery-mousewheel/jquery.mousewheel',
    'paper': '../../bower_components/paper/dist/paper'
    },
  shim: {
    'jquery': {
      exports: '$'
    }
  }
})

require ['pan_and_zoom'], (examples) ->
  examples.example1('paper1')
  examples.example2('paper2')
