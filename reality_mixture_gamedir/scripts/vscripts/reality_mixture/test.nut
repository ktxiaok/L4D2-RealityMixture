printl("reality_mixture/test");
local ctx = ::RealityMixture;

local Test = function()
{
	// local insanityController = ::RealityMixture.InsanityController.TryGetOrCreate(Ent("!player"));
	// insanityController.SetInsanity(999);




	// local trigger = Ent("trigger_01");
	// local function PrintTouchingEntities(monitor)
	// {
	// 	printl("Touching Entities: ");
	// 	foreach (ent in monitor.GetTouchingEntities())
	// 	{
	// 		printl("  " + ent);
	// 	}
	// }
	// local function OnStartTouch(args)
	// {
	// 	printl(format("OnStartTouch: %s", args.Activator.tostring()));
	// 	PrintTouchingEntities(args.Monitor);
	// }
	// local function OnEndTouch(args)
	// {
	// 	printl(format("OnEndTouch: %s", args.Activator.tostring()));
	// 	PrintTouchingEntities(args.Monitor);
	// }
	// local monitor = RealityMixture.TriggerTouchingMonitor(trigger, { StartTouchCallback = OnStartTouch, EndTouchCallback = OnEndTouch});



	// local player = Ent("!player");
	// local prop = Ent("prop_dynamic_01");
	// local trigger = SpawnEntityFromTable("script_trigger_multiple", {
	// 	spawnflags = SF_TRIGGER_ALLOW_CLIENTS,
	// 	origin = prop.GetOrigin(),
	// 	extent = Vector(100, 100, 100),
	// 	allowincap = 1
	// });
	// SetEntityParent(trigger, prop);
	// local monitor = TriggerTouchingMonitor(trigger, {
	// 	StartTouchCallback = @(args) printl("Test Trigger StartTouch"),
	// 	EndTouchCallback = @(args) printl("Test Trigger EndTouch")
	// });
	// if ("TestTrigger" in this && TestTrigger.IsValid())
	// {
	// 	TestTrigger.Kill();
	// }
	// TestTrigger <- trigger;
	// ::Test1 <- function()
	// {
	// 	prop.SetOrigin(player.GetOrigin());
	// 	printl("prop origin: " + prop.GetOrigin());
	// 	printl("trigger origin: " + trigger.GetOrigin());
	// }

	local player = Ent("!player");
	ViewController.TryGetOrCreate(player).Activate("horror_common_01", 999);
	Coroutine.Delay(@() ctx.TakeFatalDamage(player), 1).Start();
}.bindenv(ctx);
Test();