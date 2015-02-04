(function() {
  'use strict';

  /**
    * @ngdoc directive
    * @name easy.form.directives:easyInput
    *
    * @restrict AE
    *
    * @requires $log
    * @requires $q
    * @requires $timeout
    * @requires $compile
    * @requires easy.form.providers:$easyInput
    * @requires easy.form.$easyValidation
    *
    * @description
    * # easyInput
    *
    *
    * @example
     <example module="easy.form.directives">
       <file name="index.html">
           <easy-input type='text' ng-model="model1">
       </file>
     </example>
    *
   */
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  angular.module('easy.form.directives').directive("easyInput", function($log, $parse, $injector, $q, $timeout, $compile, $easyInput, $easyValidation) {

    /*
    Compile dynamic template in runtime
    @param element
    @param scope
    @param template
     */
    var $translate, guid, s4, uniqueArray, _checkValidation, _invalidFunc, _isFocusElement, _isTranslateEnable, _setElementTemplate, _validFunc;
    _setElementTemplate = function(element, scope, template) {
      element.html(template);
      return $compile(element.contents())(scope);
    };

    /**
    Do this function if validation valid
    @param element
    @param validMessage
    @param validation
    @param callback
    @param ctrl
    @returns {}
     */
    _validFunc = function(scope, element, validMessage, validation, callback, ctrl) {
      scope.$invalid = false;
      scope.invalidMessage = null;
      ctrl.$setValidity(ctrl.$name, true);
      if (scope.$dirty === true) {
        element.removeClass('has-error');
        if (callback) {
          callback();
        }
      }
      return true;
    };

    /**
    Do this function if validation invalid
    @param element
    @param validMessage
    @param validation
    @param callback
    @param ctrl
    @returns {}
     */
    _invalidFunc = function(scope, element, invalidMessage, validator, callback, ctrl) {
      scope.$invalid = true;
      ctrl.$setValidity(ctrl.$name, false);
      if (scope.$dirty === true) {
        element.addClass('has-error');
        scope.invalidMessage = $easyValidation.showInvalidMessage ? invalidMessage : null;
        if (callback) {
          callback();
        }
      }
      return false;
    };

    /**
    If var is true, focus element when validate end
    @type {boolean}
    private variable
     */
    _isFocusElement = true;

    /**
    If translate module exsited, and inject a $translate object
    @type {boolean}
    private variable
     */
    _isTranslateEnable = $injector.has('$translate');
    if (_isTranslateEnable) {
      $translate = $injector.get('$translate');
    }

    /**
    Check Validation with Function or RegExp
    @param scope
    @param element
    @param attrs
    @param ctrl
    @param validation
    @param value
    @returns {}
     */
    _checkValidation = function(scope, element, attrs, ctrl, validation, customValidationRules) {
      var errorMessage, expression, invalidMessage, leftValidation, valid, validMessage, validator;
      validator = validation[0];
      leftValidation = validation.slice(1);
      invalidMessage = $easyValidation.getInvalidMessage(validator);
      validMessage = '';
      errorMessage = validation + "ErrorMessage";
      expression = $easyValidation.getExpression(validator);
      if ((expression == null) && customValidationRules[validator]) {
        expression = customValidationRules[validator].expression;
        invalidMessage = customValidationRules[validator].messages.invalid;
      }
      valid = {
        success: function() {
          _validFunc(scope, element, validMessage, validator, scope.validCallback, ctrl);
          if (leftValidation.length) {
            return _checkValidation(scope, element, attrs, ctrl, leftValidation, customValidationRules);
          } else {
            return true;
          }
        },
        error: function() {
          return _invalidFunc(scope, element, invalidMessage, validator, scope.invalidCallback, ctrl);
        }
      };
      if (expression === undefined) {
        $log.debug("You are using undefined validator \"%s\"", validator);
        if (leftValidation.length) {
          return _checkValidation(scope, element, attrs, ctrl, leftValidation, customValidationRules);
        }
      } else if (expression.constructor === Function) {
        return $q.all([expression(scope.model, scope, element, attrs)]).then((function(data) {
          if (data && data.length > 0 && data[0]) {
            return valid.success();
          } else {
            return valid.error();
          }
        }), function() {
          return valid.error();
        });
      } else if (expression.constructor === RegExp) {
        if ($easyValidation.getExpression(validator).test(scope.model)) {
          return valid.success();
        } else {
          return valid.error();
        }
      } else {
        return valid.error();
      }
    };

    /**
    generate unique guid
     */
    s4 = function() {
      return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    };
    guid = function() {
      return s4() + s4() + s4() + s4();
    };

    /**
    Removing duplicate elements from array
     */
    uniqueArray = function(arr) {
      var key, newArr, value, _i, _ref;
      newArr = {};
      for (key = _i = 0, _ref = arr.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
        newArr[arr[key]] = arr[key];
      }
      for (key in newArr) {
        value = newArr[key];
        value;
      }
      return arr = newArr;
    };
    return {
      require: 'ngModel',
      restrict: 'AE',
      scope: {
        model: '=ngModel',
        name: '@',
        options: '=',
        type: '@',
        wrapper: '@',
        ngDisabled: '=',
        ngChange: '&',
        label: '@',
        placeholder: '@',
        hint: '@',
        labelClass: '@',
        controlClass: '@',
        wrapperClass: '@',
        validator: '@',
        validClass: '@',
        originInvalidClass: '@',
        validMethod: '@',
        customValidator: '@',
        validTriggerEvent: '@',
        initialValidity: '@',
        validCallback: '&',
        invalidCallback: '&'
      },
      link: function(scope, element, attrs, ctrl) {

        /**
        Initialize scope from options
         */
        var customRule, customValidationRules, initialValidity, input, inputElement, inputFieldElement, inputTemplate, uid, v, validMethod, validation, watch, wrapper, wrapperTemplate, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
        wrapper = $easyInput.getWrapper(scope.wrapper);
        wrapperTemplate = $easyInput.getWrapperTemplate(scope.wrapper);
        input = $easyInput.getInput(scope.type);
        inputTemplate = $easyInput.getInputTemplate(scope.type);

        /**
        Watch the model change and trigger matched callback
         */
        scope.$watch('model', function(newVal, oldVal) {
          if (newVal !== oldVal) {
            if (scope.ngChange()) {
              return scope.ngChange();
            }
          }
        });

        /**
        recognition if label and placeholder a string or a object
         */

        /**
        Set labelClass
         */
        scope.labelClassArr = scope.labelClass ? scope.labelClass.split(/[ ,]+/) : [];
        if (angular.isArray(wrapper.labelClass)) {
          (_ref = scope.labelClassArr).push.apply(_ref, wrapper.labelClass);
        }
        uniqueArray(scope.labelClassArr);

        /**
        Set controlClass
         */
        scope.controlClassArr = scope.controlClass ? scope.controlClass.split(/[ ,]+/) : [];
        if (angular.isArray(wrapper.controlClass)) {
          (_ref1 = scope.controlClassArr).push.apply(_ref1, wrapper.controlClass);
        }
        uniqueArray(scope.controlClassArr);

        /**
        Get wrapper template option and compile it
         */
        if (wrapperTemplate) {
          _setElementTemplate(element, scope, wrapperTemplate);
        }

        /**
        Get input template option and compile it
         */
        inputFieldElement = element.find('easy-input-field');
        if (inputFieldElement) {
          _setElementTemplate(inputFieldElement, scope, inputTemplate);
        }
        inputElement = inputFieldElement.children("[name='inputIn']");

        /**
        watch
        @type {watch}
        
        Use to collect scope.$watch method
        
        use watch() to destroy the $watch method
         */
        watch = function() {

          /**
          validator
          @type {Array}
          
          Convert validators and validatorRule to Array
           */
        };
        validation = [];
        customValidationRules = {};
        if (scope.customValidator != null) {
          _ref2 = scope.customValidator.split(/[ ,]+/);
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            v = _ref2[_i];
            customRule = $parse(v)(scope.$parent);
            customValidationRules[customRule.name] = customRule;
            validation.push(customRule.name);
          }
        }
        if (scope.validator != null) {
          _ref3 = scope.validator.split(/[ ,]+/);
          for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
            v = _ref3[_j];
            validation.push(v);
          }
        }
        if (validation.length !== 0) {

          /**
          set default invalid class
           */
          scope.invalidClass = scope.originInvalidClass ? scope.originInvalidClass : 'has-error';

          /**
          guid use
           */
          uid = ctrl.validationId = guid();

          /**
          Valid/Invalid Message
           */
          scope.validMessage = null;
          scope.invalidMessage = null;

          /**
          Set initial validity to false if no boolean value is transmitted
           */
          initialValidity = typeof scope.initialValidity !== "boolean" ? scope.initialValidity : false;

          /**
          Set custom initial validity
          Usage: <easy-input initial-validity="true" ... >
           */

          /**
          set and watch model $pristine and $dirty
           */
          scope.$pristine = ctrl.$pristine = true;
          scope.$dirty = ctrl.$dirty = false;
          scope.$watch('model', function(newVal, oldVal) {
            if (newVal === oldVal) {
              return;
            }
            scope.$pristine = ctrl.$pristine = false;
            return scope.$dirty = ctrl.$dirty = true;
          });

          /**
          Do the initial validation
           */
          _checkValidation(scope, element, attrs, ctrl, validation, customValidationRules);

          /**
          Use default validMethod if there is no value
           */
          validMethod = scope.validMethod ? scope.validMethod.split(/[ ,]+/) : ['watch', 'blur', 'submit'];

          /**
          Reset the validation for specific form
           */
          scope.$on(ctrl.$name + "reset-" + uid, function() {

            /**
            clear scope.$watch here
            when reset status
            clear the $watch method to prevent
            $watch again while reset the form
             */
            watch();
            _isFocusElement = false;
            ctrl.$setViewValue("");
            ctrl.$setPristine();
            ctrl.$setValidity(ctrl.$name, false);
            ctrl.$render();
            element.next().html("");
          });

          /**
          Check validator
           */
          if (__indexOf.call(validMethod, 'watch') >= 0) {

            /**
            Validate watch method
            This is the default method
             */
            scope.$watch("model", function(value) {

              /**
              dirty, pristine, viewValue control here
               */
              if (ctrl.$pristine && ctrl.$viewValue && ctrl.$invalid) {
                return _checkValidation(scope, element, attrs, ctrl, validation, customValidationRules);
              }
            });
          }
          if (__indexOf.call(validMethod, 'blur') >= 0) {

            /**
            Validate blur method
             */
            inputElement.bind("blur", function() {
              return scope.$apply(function() {
                return _checkValidation(scope, element, attrs, ctrl, validation, customValidationRules);
              });
            });
          }
          if (__indexOf.call(validMethod, 'submit') >= 0) {

            /**
            Click submit form, check the validity when submit
             */
            scope.$on(ctrl.$name + "-submit-" + uid, function(event, index) {
              var isValid;
              scope.$pristine = false;
              scope.$dirty = true;
              isValid = false;
              return isValid = _checkValidation(scope, element, attrs, ctrl, validation, customValidationRules);
            });
          }
          if (scope.validTriggerEvent != null) {

            /**
            Do validation when receive a given event command
             */
            return scope.$on(scope.validTriggerEvent, function() {
              scope.$pristine = false;
              scope.$dirty = true;
              return _checkValidation(scope, element, attrs, ctrl, validation, customValidationRules);
            });
          }
        }
      }
    };
  });

}).call(this);
