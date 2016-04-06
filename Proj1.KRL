ruleset set_one {
	meta {
		name "Part1"
		description <<
			Echo server to return the needs for part 1.
		>>
		author "Joseph Blodgett"
		logging on 
		sharing on
	}
	rule hello {
		select when echo hello 
		{
		send_directive("say") with 
			something = "Hello World"
		}
		always {
			log("Hello was fired");
		}
	}

	rule Message {
		select when echo message
		pre {
			input = event:attr("input").klog("Passed in input: ");
		}
		{
			send_directive("say") with 
				something = "#{input}";
		}
		always{
			log("Message fired with input " + input);
		}
	}
}