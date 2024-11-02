# Death

If a player or monster has 0HP at any point, and their death is not already on **the stack**, their death is put on **the stack** the next time any player would receive priority. If they can’t **prevent** or **cancel** that death by the time it **resolves**, they follow the steps for either player or monster death below. If a player or monster has an HP stat that is not a number at any point, that is considered the same as it having 0HP.

The above is also true for any other objects (e.g. attackable items or rooms) that have an HP stat. In those cases, follow the series of steps for **Monster Death** below, replacing the word ‘monster’ with the relevant object type. For example, triggered abilities that trigger from a ‘**monster**’ dying wouldn’t trigger, as it isn’t a ‘**monster**’ that has died.

Eternal objects can’t die. If an Eternal object has 0HP, the game will not attempt to put its death onto the stack.

* * *

### Monster Death

When a monster dies, the order of steps to take is as follows:

1.  It is moved out of its monster slot to a temporary holding zone.
2.  Abilities that trigger when a monster dies, but not after gaining rewards, trigger here.
3.  The active player gains any rewards from the monster.
4.  Abilities that trigger when a monster dies, after gaining rewards, trigger here.
5.  If the monster has a soul icon, it becomes a soul and the active player gains it. Otherwise, it is moved to discard.
6.  Refill monster slots, if applicable.

Priority will pass if any triggered abilities are added to the stack, as normal, but otherwise none of the above steps use the stack – they simply happen immediately once the step before is complete.

If a monster that can’t be put in discard (e.g. due to an ability it has) is killed, it will instead simply be put back in the monster slot it was in during step 6 of the above.

When an attackable object that isn’t a monster dies, the steps to follow are the same as the above, but with ‘monster’ being substituted for the type of object in question.

* * *

### Player Death

Dying consists of 4 steps. It differs if the player dying is the active player.

When an active player dies, any purchase, attack, or end declarations they make stop, any attacks they are in are cancelled, and they move to the death steps. Abilities that trigger when a player dies will specify whether they trigger before or after the death penalty is paid, where it is relevant. In any other cases, if it isn’t specified, abilities that trigger when a player dies will trigger before the death penalty step.

**Death Penalty Step:**

To perform the **death penalty**, the player who has died:

*   Chooses a non-eternal item they control (their **death penalty item**) and destroys it
*   Discards a loot card
*   Loses 1¢
*   Deactivates each object they control with a ↷ ability.

If a player can’t afford to pay any part of the death penalty, they simply don’t pay that part.

If a non-active player is going through the death steps, they stop after this step. If it is an active player, they move on to the next step.

**Cleanup Step:**

This step doesn’t end until everything currently on the stack resolves. Any empty slots must also be refilled.

**End Step:**

The turn is set to the **end phase**. The end phase itself is then carried out as normal.

A player can only die once per turn. Dead players cannot be healed by abilities or effects. All players, including dead players, heal to full at the end of every turn. If a player died on another player’s turn they would heal and be alive again as the turn passes to the next player. This means a player could die multiple times, once per turn, before they next get a turn of their own.

