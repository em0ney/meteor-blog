class @BlogController extends RouteController
  action: ->
    if @ready()
      @render()
    else if Template['loading']
      @render 'loading'

Router.map ->

  #
  # RSS Feed
  #

  if Meteor.isServer
    @route 'rss',
      where: 'server'
      path: '/rss/posts'
      action: ->
        @response.write Meteor.call 'serveRSS'
        @response.end()

  #
  # Blog Index
  #

  @route 'blogIndex',
    path: '/blog'
    controller: 'BlogController'

    onBeforeAction: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

      if not Session.get('postLimit') and Blog.settings.pageSize
        Session.set 'postLimit', Blog.settings.pageSize

    waitOn: -> [
      Meteor.subscribe 'posts', Session.get('postLimit')
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      posts: Post.where
        published: true
      ,
        sort:
          publishedAt: -1

  #
  # Blog Tag
  #

  @route 'blogTagged',
    path: '/blog/tag/:tag'
    controller: 'BlogController'

    onBeforeAction: ->
      if Blog.settings.blogIndexTemplate
        @template = Blog.settings.blogIndexTemplate

      # Set up our own 'waitOn' here since IR does not atually wait on 'waitOn'
      # (see https://github.com/EventedMind/iron-router/issues/265).
      @subscribe('taggedPosts', @params.tag).wait()

    waitOn: -> [
      Meteor.subscribe 'taggedPosts', @params.tag
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      posts: Post.where
        published: true
        tags: @params.tag
      ,
        sort:
          publishedAt: -1

  #
  # Show Blog
  #

  @route 'blogShow',
    path: '/blog/:slug'
    controller: 'BlogController'
    notFoundTemplate: 'blogNotFound'

    onBeforeAction: ->
      if Blog.settings.blogShowTemplate
        @template = Blog.settings.blogShowTemplate

        # If the user has a custom template, and not using the helper, then
        # maintain the package Javascript so that OpenGraph tags and share
        # buttons still work.
        pkgFunc = Template.blogShowBody.rendered
        userFunc = Template[@template].rendered

        if userFunc
          Template[@template].rendered = ->
            pkgFunc.call(@)
            userFunc.call(@)
        else
          Template[@template].rendered = pkgFunc

    waitOn: -> [
      Meteor.subscribe 'singlePost', @params.slug
      Meteor.subscribe 'authors'
    ]

    fastRender: true

    data: ->
      Post.first slug: @params.slug

  #
  # Blog Admin Index
  #

  @route 'blogAdmin',
    path: '/admin/blog'
    controller: 'BlogController'

    waitOn: ->
      [ Meteor.subscribe 'posts'
        Meteor.subscribe 'authors' ]

    onBeforeAction: (pause) ->

      if Blog.settings.blogAdminTemplate
        @template = Blog.settings.blogAdminTemplate

      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

  #
  # New Blog
  #

  @route 'blogAdminNew',
    path: '/admin/blog/new'

    onBeforeAction: (pause) ->

      if Blog.settings.blogAdminNewTemplate
        @template = Blog.settings.blogAdminNewTemplate

      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

  #
  # Edit Blog
  #

  @route 'blogAdminEdit',
    path: '/admin/blog/edit/:slug'
    controller: 'BlogController'

    onBeforeAction: (pause) ->
      if Blog.settings.blogAdminEditTemplate
        @template = Blog.settings.blogAdminEditTemplate

      if Meteor.loggingIn()
        return pause()

      Meteor.call 'isBlogAuthorized', (err, authorized) =>
        if not authorized
          return @redirect('/blog')

    waitOn: -> [
      Meteor.subscribe 'singlePost', @params.slug
      Meteor.subscribe 'authors'
    ]

    data: ->
      Post.first slug: @params.slug
