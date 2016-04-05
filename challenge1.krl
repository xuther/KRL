
ruleset joes_test {
  meta {
    name "Joe's Test"
    description <<
Trying out a second rule
>>
    author "Joseph Blodgett"
    logging on
    sharing on
    provides yo

  }
  global {
    yo = function(obj) {
      msg = "Hello " + obj + "2 + 2 " + 2+2
      msg
    };
 
  }
  rule hello_world {
    select when joe yo
    pre {
      name = event:attr("name").klog("our passed in Name: ");
      }
    {
    send_directive("say") with
      something = "Yo #{name}";
    }
    always {
      log ("LOG says yo " + name);
    }
  }
 }