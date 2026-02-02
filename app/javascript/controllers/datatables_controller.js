import $ from "jquery"
import "datatables.net"
import "datatables.net-bs5"

export default class extends HTMLElement {
  connect() {
    // prevent double-init on Turbo visits
    if ($.fn.dataTable.isDataTable(this.element)) return

    $(this.element).DataTable({
      processing: true,
      serverSide: true,
      ajax: this.element.dataset.source
    })
  }
}
