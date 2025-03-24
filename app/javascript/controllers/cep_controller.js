// app/javascript/controllers/cep_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["zipCode", "street", "city", "state"]



  findAddress() {
    const cep = this.zipCodeTarget.value.replace(/\D/g, '');
    if (cep.length === 8) {
      fetch(`https://viacep.com.br/ws/${cep}/json/`)
        .then(response => response.json())
        .then(data => {
          if (!data.erro) {
            // Verifica se os elementos existem antes de preenchê-los
            this.streetTarget.value = data.logradouro || '';
            this.cityTarget.value = data.localidade || '';
            this.stateTarget.value = data.uf || '';
          } else {
            alert("CEP não encontrado.");
          }
        })
        .catch(error => {
          console.error('Erro ao consultar CEP:', error);
          alert("Erro ao buscar CEP. Tente novamente.");
        });
    }
  }
  formatCep() {
    let value = this.zipCodeTarget.value.replace(/\D/g, "");
    if (value.length > 5) {
      this.zipCodeTarget.value = value.substring(0, 5) + '-' + value.substring(5, 8);
    } else {
      this.zipCodeTarget.value = value;
    }
  }

}
