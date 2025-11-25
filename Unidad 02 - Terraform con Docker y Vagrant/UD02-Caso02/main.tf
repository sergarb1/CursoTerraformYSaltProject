# 🎛️ Declaramos que se usará el provider "vagrant", publicado por "bmatcuk"
terraform {
  required_providers {
    vagrant = {
      source  = "bmatcuk/vagrant"     # Fuente del provider en el Registry
      version = "4.1.0"               # Versión fija del provider
    }
  }
}

# 🔌 Activamos el provider vagrant (no necesita configuración extra)
provider "vagrant" {}

# 💻 Recurso que representa la VM de Windows 10
resource "vagrant_vm" "win10" {
  name     = "win10-eval"  # Nombre visible en VirtualBox y vagrant global-status

  # 💡 Este valor hace que la VM se regenere si el archivo Vagrantfile cambia
  env = {
    VAGRANTFILE_HASH = md5(file("${path.module}/Vagrantfile"))
  }

  # ⚠️ Activamos la lectura de puertos para exponerlos como output
  get_ports = true
}

# 📤 Output que muestra los puertos disponibles (como el RDP 3389)
output "puertos_rdp" {
  value = vagrant_vm.win10.ports
}
