# Pin npm packages by running ./bin/importmap

pin "application"
pin "datatables.net" # @2.3.6
pin "jquery" # @4.0.0
pin "datatables.net-bs5" # @2.3.6

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.1.200

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"

