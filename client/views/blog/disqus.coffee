Template.disqus.rendered = ->
  `
  /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
  var disqus_shortname = 'elliottspira'; // required: replace example with your forum shortname

  /* * * DON'T EDIT BELOW THIS LINE * * */
  (function() {
      var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
      dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
      (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })();
  `
  ###
  # Whenever the template is rendered, trigger a Disqus reset.
  # This will find the correct thread for the current page URL.
  # See http://help.disqus.com/customer/portal/articles/472107-using-disqus-on-ajax-sites
  ###
  DISQUS?.reset(
     reload: true
     config: ->
  )

