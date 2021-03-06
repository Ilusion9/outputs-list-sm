# Description
Get entities outputs.

Credits to: https://github.com/kidfearless/output-info-plugin/

# Alliedmods
https://forums.alliedmods.net/showthread.php?t=327344

# Functions
```csharp
/**
 * Returns an output from an entity outputs list
 *
 * @param hammerId          Entity hammer id.
 * @param index             Index in the output list.
 * @param output            Buffer to copy the output name.
 * @param outputlen         Maximum size of the output buffer.
 * @param target            Buffer to copy the target name.
 * @param targetlen         Maximum size of the target buffer.
 * @param input             Buffer to copy the input received.
 * @param inputlen          Maximum size of the input buffer.
 * @param params            Buffer to copy the parameters received.
 * @param paramslen         Maximum size of the parameters buffer.
 * @param delay             Delay of the output
 * @param once              True if the output has 'Only Once' flag enabled.
 * @return                  True if the output has been returned.
 */
native bool GetHammerIdOutput(int hammerId, int index, char[] output, int outputlen, char[] target, int targetlen, char[] input, int inputlen, char[] params, int paramslen, float& delay, bool& once);

/**
 * Returns an output from an entity outputs list
 *
 * @param entity            Entity index.
 * @param index             Index in the output list.
 * @param output            Buffer to copy the output name.
 * @param outputlen         Maximum size of the output buffer.
 * @param target            Buffer to copy the target name.
 * @param targetlen         Maximum size of the target buffer.
 * @param input             Buffer to copy the input received.
 * @param inputlen          Maximum size of the input buffer.
 * @param params            Buffer to copy the parameters received.
 * @param paramslen         Maximum size of the parameters buffer.
 * @param delay             Delay of the output
 * @param once              True if the output has 'Only Once' flag enabled.
 * @return                  True if the output has been returned.
 */
native bool GetEntityOutput(int entity, int index, char[] output, int outputlen, char[] target, int targetlen, char[] input, int inputlen, char[] params, int paramslen, float& delay, bool& once);

/**
 * Returns the entity outputs count.
 *
 * @param hammerId          Entity hammer id.
 * @return                  The entity outputs count.
 */
native int GetHammerIdOutputsCount(int hammerId);

/**
 * Returns the entity outputs count.
 *
 * @param entity            Entity index.
 * @return                  The entity outputs count.
 */
native int GetEntityOutputsCount(int entity);
```

# Examples
## Get all outputs from entity index
```csharp
bool inputOnce;
char outputName[256];
char targetName[256];
char inputName[256];
char params[256];
float inputDelay;
  
for (int i = 0; i < GetEntityOutputsCount(entity); i++)
{		
	// get output
	if (!GetEntityOutput(entity, i, outputName, sizeof(outputName), targetName, sizeof(targetName), inputName, sizeof(inputName), params, sizeof(params), inputDelay, inputOnce))
	{
		continue;
	}

	// do something with this output
}
```

## Get all outputs from entity hammer id
```csharp
bool inputOnce;
char outputName[256];
char targetName[256];
char inputName[256];
char params[256];
float inputDelay;
  
for (int i = 0; i < GetHammerIdOutputsCount(hammerId); i++)
{		
	// get output
	if (!GetHammerIdOutput(hammerId, i, outputName, sizeof(outputName), targetName, sizeof(targetName), inputName, sizeof(inputName), params, sizeof(params), inputDelay, inputOnce))
	{
		continue;
	}

	// do something with this output
}
```
