angular.module 'easy.form.default'

.config ($easyInputProvider) ->
  # ----------------------------------------
  # HTML Inputs
  # ----------------------------------------
  $easyInputProvider.registerInput 'text',
    templateUrl: 'easy-form/templates/inputs/text.html'

  $easyInputProvider.registerInput 'password',
    templateUrl: 'easy-form/templates/inputs/password.html'

  $easyInputProvider.registerInput 'email',
    templateUrl: 'easy-form/templates/inputs/email.html'

  $easyInputProvider.registerInput 'datetime',
    templateUrl: 'easy-form/templates/inputs/datetime.html'

  $easyInputProvider.registerInput 'datetime-local',
    templateUrl: 'easy-form/templates/inputs/datetime-local.html'

  $easyInputProvider.registerInput 'date',
    templateUrl: 'easy-form/templates/inputs/date.html'

  $easyInputProvider.registerInput 'month',
    templateUrl: 'easy-form/templates/inputs/month.html'

  $easyInputProvider.registerInput 'time',
    templateUrl: 'easy-form/templates/inputs/time.html'

  $easyInputProvider.registerInput 'number',
    templateUrl: 'easy-form/templates/inputs/number.html'

  $easyInputProvider.registerInput 'email',
    templateUrl: 'easy-form/templates/inputs/email.html'

  $easyInputProvider.registerInput 'url',
    templateUrl: 'easy-form/templates/inputs/url.html'

  $easyInputProvider.registerInput 'search',
    templateUrl: 'easy-form/templates/inputs/search.html'

  $easyInputProvider.registerInput 'tel',
    templateUrl: 'easy-form/templates/inputs/tel.html'

  $easyInputProvider.registerInput 'color',
    templateUrl: 'easy-form/templates/inputs/color.html'

  # ----------------------------------------
  # Checkboxes and radio
  # ----------------------------------------
  $easyInputProvider.registerInput 'checkbox',
    templateUrl: 'easy-form/templates/inputs/checkbox.html'

  $easyInputProvider.registerInput 'checkboxes',
    templateUrl: 'easy-form/templates/inputs/i-boolean.html'

  $easyInputProvider.registerInput 'checkboxes-inline',
    templateUrl: 'easy-form/templates/inputs/checkboxes-inline.html'

  $easyInputProvider.registerInput 'radios',
    templateUrl: 'easy-form/templates/inputs/radios.html'

  $easyInputProvider.registerInput 'radios-inline',
    templateUrl: 'easy-form/templates/inputs/radios-inline.html'

  # ----------------------------------------
  # select
  # ----------------------------------------
  $easyInputProvider.registerInput 'select',
    templateUrl: 'easy-form/templates/inputs/select.html'

  # ----------------------------------------
  # select2
  # ----------------------------------------
  $easyInputProvider.registerInput 'select2',
    templateUrl: 'easy-form/templates/inputs/select2.html'

  # ----------------------------------------
  # date
  # ----------------------------------------
  $easyInputProvider.registerInput 'date',
    templateUrl: 'easy-form/templates/inputs/date.html'

  # ----------------------------------------
  # date_picker
  # ----------------------------------------
  $easyInputProvider.registerInput 'date_picker',
    templateUrl: 'template/easy-form/templates/inputs/date_picker.html'

  # ----------------------------------------
  # date_select
  # ----------------------------------------
  $easyInputProvider.registerInput 'date_select',
    templateUrl: 'easy-form/templates/inputs/date_select.html'

  # ----------------------------------------
  # month_picker
  # ----------------------------------------
  $easyInputProvider.registerInput 'month_picker',
    templateUrl: 'easy-form/templates/inputs/month_picker.html'

  # ----------------------------------------
  # month_select
  # ----------------------------------------
  $easyInputProvider.registerInput 'month_select',
    templateUrl: 'easy-form/templates/inputs/month_select.html'

  # ----------------------------------------
  # year_picker
  # ----------------------------------------
  $easyInputProvider.registerInput 'year_picker',
    templateUrl: 'easy-form/templates/inputs/year_picker.html'

  # ----------------------------------------
  # year_select
  # ----------------------------------------
  $easyInputProvider.registerInput 'year_select',
    templateUrl: 'easy-form/templates/inputs/year_select.html'

  # ----------------------------------------
  # textarea
  # ----------------------------------------
  $easyInputProvider.registerInput 'textarea',
    templateUrl: 'easy-form/templates/inputs/textarea.html'

  # ----------------------------------------
  # set default input
  # ----------------------------------------
  $easyInputProvider.setDefaultInput 'text'