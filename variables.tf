# Zuerst muss im vCenter in der Administration ein Benutzer angelegt werden, auf den hier verwiesen werden kann
# In der Bash-Shell können die Variablen mit export angegeben werden
# export TF_VAR_vsphere_user="username@domain"
# export TF_VAR_vsphere_password="password"
# export TF_VAR_vsphere_server="dns-name-of-vcenter-or-IP"


# Der vCenter-Administrator-User der die Berechtigungen besitzt alle Rollen und Berechtigungen anzulegen
variable "vsphere_user" {
  type = string
}

# vCenter-Admin-Passwort am besten interaktiv angeben
variable "vsphere_password" {
  type = string
}

# Der DNS-Name oder die IP-Adresse vom vCenter (VCSA)
variable "vsphere_server" {
  type = string
}

# Der Benutzername, der später verwendet werden soll und der die abgespeckten Berechtigungen erhalten soll
# Der Benutzer MUSS vorher im vCenter angelegt werden.
variable "vsphere_openshift_install_user" {
  type = string
#  default = "home.local\\patrick" # Hier muss ein Backslash escaped werden.
#  Im interaktiven Modus kann "domain\user" verwendet werden, ohne Escape-Backslash
}

# Ist der angelegte ein Benutzer oder eine Gruppe?
variable "is_vsphere_openshift_install_user_a_group" {
  type = string
  # default = "false" # Wenn das angegebene Objekt ein Benutzer ist (false), wenn es eine Gruppe ist (true)
}

# Der Name des Datacenters im vSphere
variable "vsphere_datacenter" {
  type = string
  default = "dc-home"
}

# Der Name des Computer-Cluster im vSphere
variable "vsphere_computecluster" {
  type = string
  default = "cluster-home"
}

# Der Name des Distributed Switch im vSphere, auf welchem die distributed portgroup definiert ist
variable "vsphere_distributedswitch" {
  type = string
  default = "vds-openshift"
}

# Der Name der Distributed Portgruppe im vSphere
variable "vsphere_distributedportgroup" {
  type = string
  default = "dpg-openshift-12"
}

# Der Name des Ordners in welchen die VMs installiert werden sollen
variable "vsphere_folder" {
  type = string
  default = "/dc-home/vm/test-openshift" # /Datacenter/vm/Ordnername
}

# Der Name vom Datastore, der verwendet werden soll
variable "vsphere_datastore" {
  type = string
  default = "openshift_storage"
}

variable "vsphere_resource_pool" {
  type = string
  default = "ocp"
}
