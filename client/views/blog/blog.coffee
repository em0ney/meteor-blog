Template.blogShowBody.rendered = ->
  `
  !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");
  `
  # Hide draft posts from crawlers
  if not @data.published
    $('<meta>', { name: 'robots', content: 'noindex,nofollow' }).appendTo 'head'

  $('meta[property^="og:"]').remove()
  $('meta[property^="twitter:"]').remove()

  #
  # OpenGraph tags
  #

  $('<meta>', { property: 'og:type', content: 'article' }).appendTo 'head'
  $('<meta>', { property: 'og:site_name', content: location.hostname }).appendTo 'head'
  $('<meta>', { property: 'og:url', content: location.origin + location.pathname }).appendTo 'head'
  $('<meta>', { property: 'og:title', content: "#{@data.title}" }).appendTo 'head'
  $('<meta>', { property: 'og:description', content: @data.excerpt }).appendTo 'head'

  img = @data.thumbnail()
  if img
    if not /^http(s?):\/\/+/.test(img)
      img = location.origin + img
    $('<meta>', { property: 'og:image', content: img }).appendTo 'head'

  #
  # Twitter cards
  #

  $('<meta>', { property: 'twitter:card', content: 'summary' }).appendTo 'head'
  # What should go here?
  #$('<meta>', { property: 'twitter:site', content: '' }).appendTo 'head'

  author = @data.author()
  if author.profile and author.profile.twitter
    $('<meta>', { property: 'twitter:creator', content: author.profile.twitter }).appendTo 'head'

  $('<meta>', { property: 'twitter:url', content: location.origin + location.pathname }).appendTo 'head'
  $('<meta>', { property: 'twitter:title', content: "#{@data.title}" }).appendTo 'head'
  $('<meta>', { property: 'twitter:description', content: @data.excerpt }).appendTo 'head'
  $('<meta>', { property: 'twitter:image:src', content: img }).appendTo 'head'

  #
  # Twitter share button
  #

  base = "https://twitter.com/intent/tweet"
  url = encodeURIComponent location.origin + location.pathname
  text = encodeURIComponent @data.title
  href = base + "?url=" + url + "&text=" + text

  if author.profile and author.profile.twitter
    href += "&via=" + author.profile.twitter

  $(".tw-share").attr "href", href

  #
  # Facebook share button
  #

  base = "https://www.facebook.com/sharer/sharer.php"
  url = encodeURIComponent location.origin + location.pathname
  title = encodeURIComponent @data.title
  summary = encodeURIComponent @data.excerpt
  href = base + "?s=100&p[url]=" + url + "&p[title]=" + title + "&p[summary]=" + summary

  if img
    href += "&p[images][0]=" + encodeURIComponent img

  $(".fb-share").attr "href", href

  $(".tw-share, .fb-share").click ->
     window.location.href = $(this).attr("href")
  
