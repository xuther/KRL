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
		provides generateReport, sendQuery, getVehicles, getReports
	}

	global {
		cloud_url = "https://#{meta:host()}/sky/cloud/";

		sendQuery = function(eci, mod, func) {
			resp = http:get("#{cloud_url}#{mod}/#{func}", {}.put(["_eci"], eci));
			code = resp{"status_code"}.klog("response code from query: ");
			response_content = resp{"content"}.decode();
			response_content
		}

		getVehicles = function() {
			//Whaaaa?
			WranglerIsConfusing = wranglerOS:subscriptions().klog("What we get back from first Layer: ");
			subs = WranglerIsConfusing{"subscriptions"}.klog("What we get back from subscriptions: ");
			vehicles = subs{"subscribed"}.filter(
						function(x) {
							stuff = x.values().head().klog("HEAD VALUES: ");
							stuff{"name_space"} eq "Fleet_Subscription"
						}
				);
			vehicles
		}


		generateReport = function()
		{
				vehicles = getVehicles().klog("YO. Here be your vehicles, maybe: ");			
				trips = vehicles.map( function(x) {
							stuff = x.values().head();
							eci = stuff{"event_eci"}.klog("ECIS: ");
							resp = sendQuery(eci, "b507779x5.prod","trips").klog("trips: ");
							toReturn = {}.put (["ECI"],eci)
							.put(["Trips"], resp);

							toReturn
						}
					);
				toReturn = {}.put (["Vehicles"],vehicles.length())
				.put(["Reporting"],trips.length())
				.put(["Trips"],trips);

				toReturn
		}

		getReports = function(){
			reports = ent:reports
			reports
		}
	}

	rule getNextReport {
		select when fleet report 
		always {
			set ent:reportIndex ent:reportIndex+1;

			raise explicit event startReport with 
			_reportIndex = ent:reportIndex;
		}
	}

	rule getFleetReport {
		select when explicit startReport 
		foreach getVehicless() setting (cur)
		pre {
			reportIndex = event:attr("_reportIndex").klog("Index of the report");
			stuff = cur.values().head().klog("HEAD VALUES: ");
			eci = stuff{"event_eci"}.klog("ECI: ");
		}
		{
			event:send({"cid":eci},"car","report") 
			with attrs = {}
			.put(["reportIndex"], reportIndex)
			.put(["parent"], meta:eci());
		}
	}

	rule acceptReports {
		select when fleet report_sent
		pre {
			carEci = event:attr("eci").klog("Car reporting: ");
			trips = event:attr("trips").klog("Trips reported: ");
			reportIndex = event:attr("reportIndex").klog("Report sent");
			numReported = ent:reports{[reportIndex, "Reported"]};
		}
		fired {
			set ent:reports{[reportIndex, carEci]} trips.decode();
			set ent:reports{[reportIndex, "Reported"]} ent:reports{[reportIndex, "Reported"]}+1;
			log("Got a report: ");
		}
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