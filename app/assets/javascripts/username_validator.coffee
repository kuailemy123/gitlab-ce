class UsernameValidator
  constructor: (@inputElement) ->
    @DEFAULT_DEBOUNCE_TIMEOUT_LENGTH = 1000
    @ICON_HTML = '<i></i>'
    @ERROR_ICON = 'fa fa-exclamation-circle error'
    @ERROR_MESSAGE = 'Username is in use!'
    @LOADING_ICON = 'fa fa-spinner fa-spin'
    @SUCCESS_ICON = 'fa fa-check-circle success'
    @TOOLTIP_PLACEMENT = 'left'

    @iconElement = $('i', @inputElement.parent().append @ICON_HTML)

    @inputElement.keyup => @debounceRequest()

  debounceRequest: (e) ->
    clearTimeout @debounceTimeout if @debounceTimeout
    @iconElement.removeClass().tooltip 'destroy'
    return if @inputElement.val() is ''
    @iconElement.addClass @LOADING_ICON

    @debounceTimeout = setTimeout =>
      @validateUsername()
    , @DEFAULT_DEBOUNCE_TIMEOUT_LENGTH

  validateUsername: ->
    $.ajax
      type: 'GET'
      url: '/u/' + @inputElement.val() + '/exists'
      dataType: 'json'
      success: =>
        @iconElement.removeClass().addClass @ERROR_ICON
          .tooltip
            title: @ERROR_MESSAGE.replace 'Username', "Username '#{@inputElement.val()}'"
            placement: @TOOLTIP_PLACEMENT
      error: =>
        @iconElement.removeClass().addClass @SUCCESS_ICON
          .tooltip 'destroy'

$ -> $('#new_user_username').each -> new UsernameValidator $(this)
