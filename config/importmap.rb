# Pin npm packages by running ./bin/importmap

pin "application"

# Hotwire
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Action Cable (use the Rails-shipped ESM file)
pin "@rails/actioncable", to: "actioncable.esm.js"

# Your local code (lets you import "controllers/..." and "channels/...")
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"

# jQuery + DataTables (pin to real URLs so you don't get /assets/<name> 404)
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
pin "datatables.net", to: "https://cdn.datatables.net/2.3.6/js/dataTables.mjs"
pin "datatables.net-bs5", to: "https://cdn.datatables.net/2.3.6/js/dataTables.bootstrap5.mjs"
