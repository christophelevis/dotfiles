x=1
while [ $x -le 999 ]
do
  echo "Group $x"
  random_name=$(curl http://randomword.setgetgo.com/get.php | tr -d '[[:space:]]') 
  curl -u admin:admin -X POST "http://localhost:9000/api/user_groups/create?name=$random_name$x&description=$random_name"
  echo " "

  x=$(( $x + 1 ))
done
