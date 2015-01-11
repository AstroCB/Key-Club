var obj = {
  "car_wash": {
      "pretty_name": "Car Wash",
      "date": "11/14",
      "chairs": ["Vincent", "Kevin", "Anton"],
      "participants": ["Jonah", "Yiyi", "Affan"]
    },
    "mpt": {
        "date": "11/14",
        "chairs": "Vin",
        "participants": ["Jonah", "Yiyi"]
      }
};

function getDescription(event){
  var str = "This event is " + obj[event].pretty_name + " and it is on " + obj[event].date + ". The chairs are ";

  for(var i = 0; i < obj[event].chairs.length; i++){
    if(i !== obj[event].chairs.length - 1){
      str += obj[event].chairs[i] + ", ";
    }else{
      str += "and " + obj[event].chairs[i] + " and the participants are ";
    }
  }

  for(var j = 0; j < obj[event].participants.length; j++){
    if(j !== obj[event].participants.length - 1){
      str += obj[event].participants[j] + ", ";
    }else{
      str += "and " + obj[event].participants[j] + ". ";
    }
  }

  return str;

}
