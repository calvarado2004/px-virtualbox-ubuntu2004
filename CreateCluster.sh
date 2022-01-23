
export VAGRANT_EXPERIMENTAL="disks"

vagrant up --provider=virtualbox

sleep 60s

vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes"

echo Lets wait for all the nodes to become available. Sleeping for 60 seconds...

sleep 60s

#echo Restarting nodes...
#
#vagrant ssh master -c "sudo shutdown -r now"
#vagrant ssh worker0 -c "sudo shutdown -r now"
#vagrant ssh worker1 -c "sudo shutdown -r now"
#vagrant ssh worker2 -c "sudo shutdown -r now"

#echo Lets wait for all the nodes to become available. Sleeping for two minutes...

#sleep 120s

echo Continue...


vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f 'https://install.portworx.com/2.9?comp=prometheus-operator&kbver=1.22.4'"

vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf label nodes worker0.calvarado04.com worker1.calvarado04.com worker2.calvarado04.com px/metadata-node=true"
vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /tmp/portworx-enterprise.yaml"

vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes"

sleep 60s

vagrant ssh master -c "sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -o wide -n kube-system -l name=portworx"


