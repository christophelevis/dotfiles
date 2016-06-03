x=1
echo "User $x"
random_user_name=$(curl http://randomword.setgetgo.com/get.php | tr -d '[[:space:]]')
curl -u admin:admin -X POST "http://localhost:9000/api/users/create?login=$random_user_name$x&name=$random_user_name&password=test&password_confirmation=test"
echo " "

y=1
while [ $y -le 1200 ]
do
  echo "Group $y"
  random_group_name=$(curl http://randomword.setgetgo.com/get.php | tr -d '[[:space:]]') 
  curl -u admin:admin -X POST "http://localhost:9000/api/user_groups/create?name=$random_group_name$y&description=$random_group_name"
  curl -u admin:admin -X POST "http://localhost:9000/api/user_groups/add_user?name=$random_group_name$y&login=$random_user_name$x"
  echo " "

  y=$(( $y + 1 ))
done
