# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
console.log("welcome.coffee")

class WelcomeController
  index: ->
    console.log("WelcomeController#index")
    $("#main-form").submit (e) ->
      url = "/users/" + $("#user_id").val()
      console.log("url:" + url)
      $.ajax({
        type: "GET",
        url: url,
        data: $("#main-form").serialize(),
        success: (data) ->
          $("#weed").html(data)
          $("#btn-submit").prop("disabled", false)
      })
      e.preventDefault()

Shiiba.welcome = new WelcomeController

