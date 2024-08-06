for host in node-0 node-1 ctlnode; do
	ssh $host sudo shutdown now
done
