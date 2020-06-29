#### Kubernetes StatefulSet for rqlite (sqlite database cluster)
In many applications sqlite is used as a lightweight database and it is usually bundled  with the android platform. While sqlite does not support replication or clustering, there is an open source project called rqlite, to create a cluster of sqlite database instances, with one Leader and many Followers. 

Here, we have a Kubernetes StatefulSet to deploy [rqlite](https://github.com/rqlite/rqlite) on a Kubernetes environment.

The code is mostly self-explanatory. The only assumption made is that, at least one of the first three replicas (ordinal 0, 1, 2) in the StatefulSet must be up and running, for any new replica to be added into the cluster. Initially the replica with ordinal 0 becomes the Leader. Thereafter, any replica can become Leader based on election process supported by rqlite (only one Leader is allowed). If there are more than 5 replicas, these replicas become non-voting members (but you can choose a higher number, say 9, with a small change in the code).

A few test cases are described below, to explain how this StatefulSet can be used in dev / test environments.

##### Test Cases
We use minikube for these tests. But any other Kubernetes environment may also be used.

These tests need us to have adequate number of persistent volumes (PV). An example PV is given (`pv.yml`). Please tweak it as needed.

Also, pull the rqlite docker image in advance: `docker pull rqlite/rqlite`.

###### Set up an Initial Cluster
1. Start minikube: `sudo minikube start --vm-driver=none`
2. Create at least three persistent volumes (see `pv.yml`: change the PV name to `pv0`, `pv1`, and `pv2` respectively, and let the file paths be `/tmp/pv0`, `/tmp/pv1`, and `/tmp/pv2` respectively.), as in `sudo kubectl apply -f pv0.yml`.
3. Create the cluster (StatefulSet): `sudo kubectl apply -f rqsts.yml`.
4. In another terminal, observe the replicas come up in a sequence: `sudo kubectl get pods -l app=rqlite -w`. When all the replicas are running, we should see aoutput like: `rqdb-2   1/1     Running             0          28s` for each of the replicas (`rqdb-0`, `rqdb-1`, and `rqdb-2`).
5. Simultaneously with Step 4 above, check the logs of each replica, in separate terminals: `sudo kubectl logs -f rqdb-0` (similarly for `rqdb-1` and `rqdb-2`).For the Follower nodes, there should be a message like: `[rqlited] 2020/06/27 07:37:29 successfully joined cluster at http://rqdb-0.rqlite.default.svc.cluster.local:4001/join`. On the Leader, there will be messages like: `[store] 2020/06/27 07:37:29 received request to join node at 172.17.0.5:4002`, and `2020-06-27T07:37:29.557Z [INFO]  raft: Added peer rqdb-1, starting replication`.
6. Check that the Persistent Volume Claims are bound: `sudo kubectl get pvc`. There should be an output corresponding to each replica, like: `data-rqdb-0   Bound    pv0      512Mi      RWO            standard       6m23s`.

###### Test Database Replication
1. For each replica, open a shell in each pod: `sudo kubectl exec -it rqdb-0 /bin/bash` (similarly for `rqdb-1` and `rqdb-2`).
2. On the Leader node bring up a rqlite SQL prompt: `rqlite -H rqdb-0.rqlite.default.svc.cluster.local`
3. Create a simple table: `create table mytab (x text)`, and insert a row: `insert into mytab values("a")`.
4. In each replica node, bring up rqlite SQL prompt, e.g.: `rqlite -H rqdb-1.rqlite.default.svc.cluster.local`, and check that the table contents are acessible: `select * from mytab`.

###### Simulate Failure (Follower Node)
1. Let's say `rqdb-0` is currently the Leader and `rqdb-1` is therefore a Follower. From a new terminal, recycle `rqdb-1`, as in `sudo kubectl delete pod rqdb-1`.
2. After a grace period of 90 seconds, the log messages in the Leader (`rqdb-0`) should indicate something like: `[store] 2020/06/27 07:49:21 received request to remove node rqdb-1`.
3. Keep watching the pod statuses. At the moment when the pod `rqdb-1` transitions from Terminating to ContainerCreating, add a row to the database from the rqlite SQL prompt on the Leader: `insert into mytab values("b")`
4. When finally `rqdb-1` is Ready, open a shell in it again, and bring up rqlite SQL prompt. Check that the row added while it was still not up, is accessible: `select * from mytab`.

###### Simulate Failure (Leader Node)
1. For simplicity, we will clean up and start the test from scratch (although this is not necessary). Stop and delete minikube: `sudo minikube stop` followed by `sudo minikube delete`. Then start minikube again: `sudo minikube start --vm-driver=none`
2.Create three PVs, and again create the StatefulSet, and create a table with a few rows (see above).
3. Let's say `rqdb-0` is now the Leader. From a terminal, recycle this pod: `sudo kubectl delete rqdb-0`.
4. Let's say now `rqdb-1` becomes the Leader. (This can be checked by opening a shell in each of the running replicas and checking: `curl rqdb-1.rqlite.default.svc.cluster.local:4001/status?pretty | grep state` - it should indicate 'Leader', or else repeat for `rqdb-2`.)
5. Keep watching the pod statuses. Just when `rqdb-0` transitions from `Terminating` to `Ready`, from an rqlite SQL prompt on `rqdb-1`, add a row to the database: `insert into mytab values("c")`
6. Now open a shell in the (restarted) `rqdb-0` pod, and check from an rqlite SQL prompt, that the data inserted when it was down, is accessible: `select * from mytab`.

###### Scale-Out and Scale-In
1. For simplicity, we will clean up and start the test from scratch (although this is not necessary). Stop and delete minikube: `sudo minikube stop` followed by `sudo minikube delete`. Then start minikube again: `sudo minikube start --vm-driver=none`.
2. Create three PVs, and again create the StatefulSet, and create a table with a few rows (see above).
3. Scale-out: First create two more PVs. Then from a terminal, run `sudo kubectl scale sts rqdb --replicas=5`
4. Keep watching the pod statuses: two new pods will be created in sequence, as in : `rqdb-3   1/1     Running             0          26s`.
5. Open a shell in each of the new pods, and ensure that the data is accessible, using rqlite SQL prompt.
6. Scale-in: From a terminal , run `sudo kubectl scale sts rqdb --replicas=3`. PVs have to be manually deleted.
7. Keep watching the pod statuses. It should indicate something like: `rqdb-4   0/1     Terminating         0          5m23s`

###### Non-voter Replicas
In the Scale-out test above, if the maximum number of voter nodes is exceeded (5 in our code, but it can be changed), when a new replica comes up, there should be a log message in the Leader node, like: `2020-06-27T09:19:55.934Z [INFO]  raft: pipelining replication to peer {Nonvoter rqdb-3 172.17.0.7:4002}`.

Note: The above tests can be performed with minikube and vm-driver set to docker as well (without using sudo): `minikube start --vm-driver=docker`.

TO DO: \
i. PodAntiAffinityRules may be added, suitable for your Kubernetes environment. \
ii. Storage space should obviously be increased from 512 MB for each replica, when you want to store more data. \
iii. Cluster Domain may be set appropriately (instead of using the default `cluster.local`). \
iv. A separate service can be created for each pod, if needed, to access the HTTP port 4001 for each pod externally.

