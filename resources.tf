# Die folgenden Data-Objekte müssen bereits existieren.

# Datacenter-Name definieren
data "vsphere_datacenter" "dc" {
  name = "dc-home"
}


# Compute-Cluster-Name definieren
data "vsphere_compute_cluster" "cluster" {
  name            = var.vsphere_computecluster
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

# Ordner-Namen definieren, wohin die OCP-VMs deployed werden sollen
data "vsphere_folder" "folder" {
  path = var.vsphere_folder
}

# Auf den obersten Ordner (das vCenter-Object) muss die Rolle 1 berechtigt werden. Doch beim Terraform-Destroy kommt es
# zu unerwarteten Verhalten. Terraform möchte den Administrator löschen

/*
data "vsphere_folder" "vcenterroot" {
  path = "/"
}
*/

# Datastore definieren, der verwendet werden darf
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

# Netzwerk-Distributed-Portgroup definieren
data "vsphere_network" "net" {
  name          = var.vsphere_distributedportgroup
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

# Netzwerk Distributed Switch definieren
data "vsphere_distributed_virtual_switch" "vswitch" {
  name          = var.vsphere_distributedswitch
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

# Ressource Pool definieren
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Die folgenden Rollen wurden anhand der Dokumentation von OpenShift angelegt.
# https://docs.openshift.com/container-platform/4.10/installing/installing_vsphere/installing-vsphere-installer-provisioned-network-customizations.html#installation-vsphere-installer-infra-requirements_installing-vsphere-installer-provisioned-network-customizations
# Anlegen der vCenter-Rolle. Überwiegend Rechte zum Taggen definieren.

resource vsphere_role "role1" {
  name = "ocpvSpherevCenter"
  role_privileges = ["Cns.Searchable","InventoryService.Tagging.AttachTag","InventoryService.Tagging.CreateCategory","InventoryService.Tagging.CreateTag","InventoryService.Tagging.DeleteCategory","InventoryService.Tagging.DeleteTag","InventoryService.Tagging.EditCategory","InventoryService.Tagging.EditTag","Sessions.ValidateSession","StorageProfile.Update","StorageProfile.View"]
}

# Rolle, die nur auf das Cluster-Objekt anzuwenden ist
resource vsphere_role "role2" {
  name = "ocpvSpherevCenterCluster"
  role_privileges = ["Host.Config.Storage","Resource.AssignVMToPool","VApp.AssignResourcePool","VApp.Import","VirtualMachine.Config.AddNewDisk"]
}

# Rolle, die nur auf das Datastore-Objekt anzuwenden ist
resource vsphere_role "role3" {
  name = "ocpvSphereDatastore"
  #role_privileges = ["Datastore.AllocateSpace","Datastore.Browse","Datastore.FileManagement","InventoryService.Tagging.ObjectAttachable"]
  role_privileges = ["Datastore.AllocateSpace","Datastore.Browse","Datastore.FileManagement"]
}

# Rolle, die nur auf die Netzwerk-Portgruppe-Objekt anzuwenden ist
resource vsphere_role "role4" {
  name = "ocpvSpherePortGroup"
  role_privileges = ["Network.Assign"]
}

# Rolle, die nur auf den Ordner, in dem die VMs ausgerollt werden angewendet werden
resource vsphere_role "role5" {
  name = "ocpVirtualMachineFolder"
  role_privileges = ["Resource.AssignVMToPool","VApp.Import","VirtualMachine.Config.AddExistingDisk","VirtualMachine.Config.AddNewDisk","VirtualMachine.Config.AddRemoveDevice","VirtualMachine.Config.AdvancedConfig","VirtualMachine.Config.Annotation","VirtualMachine.Config.CPUCount","VirtualMachine.Config.DiskExtend","VirtualMachine.Config.DiskLease","VirtualMachine.Config.EditDevice","VirtualMachine.Config.Memory","VirtualMachine.Config.RemoveDisk","VirtualMachine.Config.Rename","VirtualMachine.Config.ResetGuestInfo","VirtualMachine.Config.Resource","VirtualMachine.Config.Settings","VirtualMachine.Config.UpgradeVirtualHardware","VirtualMachine.Interact.GuestControl","VirtualMachine.Interact.PowerOff","VirtualMachine.Interact.PowerOn","VirtualMachine.Interact.Reset","VirtualMachine.Inventory.Create","VirtualMachine.Inventory.CreateFromExisting","VirtualMachine.Inventory.Delete","VirtualMachine.Provisioning.Clone","VirtualMachine.Provisioning.MarkAsTemplate","VirtualMachine.Provisioning.DeployTemplate"]
}

resource vsphere_role "role6" {
  name = "ocpvSpherevCenterDatacenter"
  role_privileges = ["Resource.AssignVMToPool","VApp.Import","VirtualMachine.Config.AddExistingDisk","VirtualMachine.Config.AddNewDisk","VirtualMachine.Config.AddRemoveDevice","VirtualMachine.Config.AdvancedConfig","VirtualMachine.Config.Annotation","VirtualMachine.Config.CPUCount","VirtualMachine.Config.DiskExtend","VirtualMachine.Config.DiskLease","VirtualMachine.Config.EditDevice","VirtualMachine.Config.Memory","VirtualMachine.Config.RemoveDisk","VirtualMachine.Config.Rename","VirtualMachine.Config.ResetGuestInfo","VirtualMachine.Config.Resource","VirtualMachine.Config.Settings","VirtualMachine.Config.UpgradeVirtualHardware","VirtualMachine.Interact.GuestControl","VirtualMachine.Interact.PowerOff","VirtualMachine.Interact.PowerOn","VirtualMachine.Interact.Reset","VirtualMachine.Inventory.Create","VirtualMachine.Inventory.CreateFromExisting","VirtualMachine.Inventory.Delete","VirtualMachine.Provisioning.Clone","VirtualMachine.Provisioning.DeployTemplate","VirtualMachine.Provisioning.MarkAsTemplate","Folder.Create","Folder.Delete"]
}

# Siehe oben. Hier gab es beim Löschen Probleme

/*
# Erlaubnis auf das Folder-Objekt
resource "vsphere_entity_permissions" p1 {
  entity_id = data.vsphere_folder.vcenterroot.id
  entity_type = "Folder"
  permissions {
    user_or_group = "home.local\\patrick"
    propagate = false
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role1.id
  }
}
*/

# Erlaubnis auf das Cluster-Objekt
resource "vsphere_entity_permissions" p2 {
  entity_id = data.vsphere_compute_cluster.cluster.id
  entity_type = "ClusterComputeResource"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = true
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role2.id
  }
}

# Erlaubnis auf das DataStore-Objekt
resource "vsphere_entity_permissions" p3 {
  entity_id = data.vsphere_datastore.datastore.id
  entity_type = "Datastore"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = false
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role3.id
  }
}

# Erlaubnis auf das Network-Objekt
resource "vsphere_entity_permissions" p4 {
  entity_id = data.vsphere_network.net.id
  entity_type = "Network"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = false
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role4.id
  }
}

# Erlaubnis auf das virtual-distributed-switch-Objekt
resource "vsphere_entity_permissions" p8 {
  entity_id = data.vsphere_distributed_virtual_switch.vswitch.id
  entity_type = "VmwareDistributedVirtualSwitch"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = false
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role4.id
  }
}
# Erlaubnis auf das Folder-Objekt
resource "vsphere_entity_permissions" p5 {
  entity_id = data.vsphere_folder.folder.id
  entity_type = "Folder"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = true
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role5.id
  }
}
# Erlaubnis auf das Datacenter-Objekt
resource "vsphere_entity_permissions" p6 {
  entity_id = data.vsphere_datacenter.dc.id
  entity_type = "Datacenter"
  permissions {
    user_or_group = var.vsphere_openshift_install_user
    propagate = false
    is_group = var.is_vsphere_openshift_install_user_a_group
    role_id = vsphere_role.role6.id
  }
}
