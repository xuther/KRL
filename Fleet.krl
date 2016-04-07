ruleset manage_fleet {
	meta {
		name "Manage Fleet"
		description << 
			Parent pico to manage multiple vehicile picos 
			>> 
		author "Joseph Blodgett"
		logging on 
		sharing on
		use module b507199x5 alias wranglerOS
	}

	rule create_vehicle {
		select when car new_vehicle 
		pre {
			carName = event:attr("name").klog("Name: ");
			parentECI = meta:eci();

			attributes = {}
				.put (["Prototype_rids"], "b507779x6.prod;b507779x4.prod;b507779x5.prod")
				.put (["name"],carName)
				.put (["parent_eci"], parentECI)

		}
		{
			event:send({"cid":meta:eci()},"wrangler", "child_creation")
			with attrs = attributes.klog("attributes: ");
		}
		always {
			log("Created a child for " + child);
			log("CarID: " + _carID);
		}
	}

	rule test {
		select when wrangler child_deletion 
		pre {
			eciDeleted = event:attr("deletionTarget").defaultsTo("", standardError("missing pico for deletion"));
		}
		{
			send_directive("say") with 
			something = "I Was fired!!";
		}
		always {
			log("The wrangler event was fired. " + eciDeleted);
		}
	}

	rule delete_vehicle {
		select when car unneeded_vehicle
		pre {
			picoECIToDelete = event:attr("eci").klog("Pico to Delete: ");
			subscriptionToDelete = event:attr("name").klog("Name of subscription to delete: ");
			results = wranglerOS:children();
			children = results{"children"}.klog("Children: ");
			//gotta figure out how to go name -> ECI. I can get the ECI with the wranglerOS.children.
			
		}
		{
			event:send({"cid":meta:eci()}, "wrangler", "child_deletion") 
				with attrs = {}.put(["deletionTarget"], picoECIToDelete).klog("attributes for delete: ");
		    event:send({"cid":meta:eci()}, "wrangler", "subscription_cancellation") 
				with attrs = {}.put(["channel_name"], subscriptionToDelete).klog("attributes for unsubscription: ");
		}
		always {
			log("deleting child Pico");
		}
	}

	rule autoAccept {
		select when wrangler inbound_pending_subscription_added 
		pre {
			attributes = event:attrs().klog("Subscription: ");
		}
		{
			noop();
		}
		always{
			raise wrangler event 'pending_subscription_approval'
				attributes attributes;
				log("auto accepted subscription.");
		}
	}
}