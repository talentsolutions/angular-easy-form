'use strict'

###*
 # @ngdoc directive
 # @name easy.form.directives:easyInput
 #
 # @restrict AE
 #
 # @requires $log
 # @requires $q
 # @requires $timeout
 # @requires $compile
 # @requires easy.form.providers:$easyInput
 # @requires easy.form.$easyValidation
 #
 # @description
 # # easyInput
 #
 #
 # @example
   <example module="easy.form.directives">
     <file name="index.html">
         <easy-input type='text' ng-model="model1">
     </file>
   </example>
 #
###

angular.module('easy.form.directives')
.directive "easyInput", ($log, $parse, $injector, $q, $timeout, $compile, $easyInput, $easyValidation) ->

  ###
  Compile dynamic template in runtime
  @param element
  @param scope
  @param template
  ###
  _setElementTemplate = (element, scope, template) ->
    element.html(template)
    $compile(element.contents())(scope)

  ###*
  Do this function if validation valid
  @param element
  @param validMessage
  @param validation
  @param callback
  @param ctrl
  @returns {}
  ###
  _validFunc = (scope, element, validMessage, validation, callback, ctrl) ->
    scope.$invalid = false
    scope.invalidMessage = null
    ctrl.$setValidity ctrl.$name, true
    if scope.$dirty is true
      element.removeClass('has-error')
      callback() if callback
    true

  ###*
  Do this function if validation invalid
  @param element
  @param validMessage
  @param validation
  @param callback
  @param ctrl
  @returns {}
  ###
  _invalidFunc = (scope, element, invalidMessage, validator, callback, ctrl) ->
    scope.$invalid = true
    ctrl.$setValidity ctrl.$name, false
    if scope.$dirty is true
      element.addClass('has-error')
      scope.invalidMessage = if $easyValidation.showInvalidMessage then invalidMessage else null
      callback()  if callback
    false

  ###*
  If var is true, focus element when validate end
  @type {boolean}
  private variable
  ###
  _isFocusElement = true


  ###*
  If translate module exsited, and inject a $translate object
  @type {boolean}
  private variable
  ###
  _isTranslateEnable = $injector.has '$translate'
  $translate = $injector.get '$translate' if _isTranslateEnable

  ###*
  Check Validation with Function or RegExp
  @param scope
  @param element
  @param attrs
  @param ctrl
  @param validation
  @param value
  @returns {}
  ###
  _checkValidation = (scope, element, attrs, ctrl, validation, customValidationRules) ->
    validator = validation[0]
    leftValidation = validation.slice(1)
    invalidMessage = $easyValidation.getInvalidMessage(validator)
    validMessage = ''
    errorMessage = validation + "ErrorMessage"
    expression = $easyValidation.getExpression(validator)
    if not expression? and customValidationRules[validator]
      expression = customValidationRules[validator].expression
      invalidMessage = customValidationRules[validator].messages.invalid

    valid =
      success: ->
        _validFunc scope, element, validMessage, validator, scope.validCallback, ctrl
        if leftValidation.length
          _checkValidation scope, element, attrs, ctrl, leftValidation, customValidationRules
        else
          true
      error: ->
        _invalidFunc scope, element, invalidMessage, validator, scope.invalidCallback, ctrl

    if expression is `undefined`
      $log.debug "You are using undefined validator \"%s\"", validator
      if leftValidation.length
        _checkValidation scope, element, attrs, ctrl, leftValidation, customValidationRules
    else if expression.constructor is Function
      $q.all([expression(scope.model, scope, element, attrs)]).then ((data) ->
        if data and data.length > 0 and data[0]
          valid.success()
        else
          valid.error()
      ), ->
        valid.error()

      # Check with RegExp
    else if expression.constructor is RegExp
      (if $easyValidation.getExpression(validator).test(scope.model) then valid.success() else valid.error())
    else
      valid.error()

  ###*
  generate unique guid
  ###
  s4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  guid = ->
    s4() + s4() + s4() + s4()


  ###*
  Removing duplicate elements from array
  ###
  uniqueArray = (arr)->
    newArr = {}
    newArr[arr[key]] = arr[key] for key in [0...arr.length]
    value for key, value of newArr
    arr = newArr

  return (
    require: 'ngModel'
    restrict: 'AE'
    scope:
      model: '=ngModel'
      name: '@'
      options: '='
      # template
      type: '@'
      wrapper: '@'
      # native behaviour
      ngDisabled: '='
      ngChange: '&'
      # label & placeholder
      label: '@'
      placeholder: '@'
      hint: '@'
      # style
      labelClass: '@'
      controlClass: '@'
      wrapperClass: '@'
      # validation
      validator: '@'
      validClass: '@'
      originInvalidClass: '@'
      validMethod: '@'
      customValidator: '@'
      validTriggerEvent: '@'
      initialValidity: '@'
      validCallback: '&'
      invalidCallback: '&'
    link: (scope, element, attrs, ctrl) ->
      ###*
      Initialize scope from options
      ###
#      if scope.options
#        optionKeys = ['type'
#                      'wrapper'
#                      'ngDisabled'
#                      'label'
#                      'placeholder'
#                      'labelClass'
#                      'controlClass'
#                      'changeCallback'
#                      'validCallback'
#                      'inValidCallback']
#        scope[key] = scope.options[key] for key in optionKeys when scope.options[key]
      wrapper = $easyInput.getWrapper(scope.wrapper)
      wrapperTemplate = $easyInput.getWrapperTemplate(scope.wrapper)
      input = $easyInput.getInput(scope.type)
      inputTemplate = $easyInput.getInputTemplate(scope.type)

      ###*
      Watch the model change and trigger matched callback
      ###
      scope.$watch 'model', (newVal, oldVal)->
        unless newVal is oldVal
          scope.ngChange() if scope.ngChange()

      ###*
      recognition if label and placeholder a string or a object
      ###
      #      scope.label = attrs.label if angular.isUndefined(scope.label) and angular.isString(attrs.label)
      #      scope.placeholder = attrs.placeholder if angular.isUndefined(scope.placeholder) and angular.isString(attrs.placeholder)

      ###*
      Set labelClass
      ###
      scope.labelClassArr = if scope.labelClass then scope.labelClass.split(/[ ,]+/) else []
      scope.labelClassArr.push (wrapper.labelClass)... if angular.isArray(wrapper.labelClass)
      uniqueArray(scope.labelClassArr)

      ###*
      Set controlClass
      ###
      scope.controlClassArr = if scope.controlClass then scope.controlClass.split(/[ ,]+/) else []
      scope.controlClassArr.push (wrapper.controlClass)... if angular.isArray(wrapper.controlClass)
      uniqueArray(scope.controlClassArr)

      ###*
      Get wrapper template option and compile it
      ###
      if wrapperTemplate then _setElementTemplate(element, scope, wrapperTemplate)

      ###*
      Get input template option and compile it
      ###
      inputFieldElement = element.find('easy-input-field')
      if inputFieldElement then _setElementTemplate(inputFieldElement, scope, inputTemplate)
      inputElement = inputFieldElement.children("[name='inputIn']")
      ###*
      watch
      @type {watch}

      Use to collect scope.$watch method

      use watch() to destroy the $watch method
      ###
      watch = ->

        ###*
        validator
        @type {Array}

        Convert validators and validatorRule to Array
        ###
        # customValidator = { name: 'name', expression: /^\d+$/, messages: {invalid: 'error!'}, translate: true }
      validation = []
      customValidationRules = {}
      if scope.customValidator?
        for v in scope.customValidator.split((/[ ,]+/))
          customRule = $parse(v)(scope.$parent)
          customValidationRules[customRule.name] = customRule
          validation.push customRule.name

      validation.push v for v in scope.validator.split((/[ ,]+/)) if scope.validator?

      unless validation.length is 0
        ###*
        set default invalid class
        ###
        scope.invalidClass = if scope.originInvalidClass then scope.originInvalidClass else 'has-error'


        ###*
        guid use
        ###
        uid = ctrl.validationId = guid()

        ###*
        Valid/Invalid Message
        ###
        scope.validMessage = null
        scope.invalidMessage = null

        ###*
        Set initial validity to false if no boolean value is transmitted
        ###
        initialValidity = if typeof scope.initialValidity isnt "boolean" then scope.initialValidity else false

        ###*
        Set custom initial validity
        Usage: <easy-input initial-validity="true" ... >
        ###
        # scope.$invalid != ctrl.$setValidity ctrl.$name, initialValidity

        ###*
        set and watch model $pristine and $dirty
        ###
        scope.$pristine = ctrl.$pristine = true
        scope.$dirty = ctrl.$dirty  = false

        scope.$watch 'model', (newVal, oldVal)->
          return if newVal is oldVal
          scope.$pristine = ctrl.$pristine = false
          scope.$dirty = ctrl.$dirty = true

        ###*
        Do the initial validation
        ###
        _checkValidation scope, element, attrs, ctrl, validation, customValidationRules

        ###*
        Use default validMethod if there is no value
        ###
        validMethod = if scope.validMethod then scope.validMethod.split(/[ ,]+/) else ['watch', 'submit']

        ###*
        Reset the validation for specific form
        ###
        scope.$on ctrl.$name + "reset-" + uid, ->
          ###*
          clear scope.$watch here
          when reset status
          clear the $watch method to prevent
          $watch again while reset the form
          ###
          watch()
          _isFocusElement = false
          ctrl.$setViewValue ""
          ctrl.$setPristine()
          ctrl.$setValidity ctrl.$name, false
          ctrl.$render()
          element.next().html ""
          return


        ###*
        Check validator
        ###
        if 'watch' in validMethod
          ###*
          Validate watch method
          This is the default method
          ###
          scope.$watch "model", (value) ->
            ###*
            dirty, pristine, viewValue control here
            ###
            if !ctrl.$pristine and ctrl.$viewValue and ctrl.$invalid
              _checkValidation scope, element, attrs, ctrl, validation, customValidationRules

        if 'submit' in validMethod
          ###*
          Click submit form, check the validity when submit
          ###
          scope.$on ctrl.$name + "-submit-" + uid, (event, index)->
            scope.$pristine = false
            scope.$dirty = true

            isValid = false

            isValid = _checkValidation scope, element, attrs, ctrl, validation, customValidationRules

        if scope.validTriggerEvent?
          ###*
          Do validation when receive a given event command
          ###
          scope.$on scope.validTriggerEvent, ->
            scope.$pristine = false
            scope.$dirty = true
            _checkValidation scope, element, attrs, ctrl, validation, customValidationRules

  )