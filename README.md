# Description
Get entities outputs.

Credits to: https://github.com/kidfearless/output-info-plugin/

# Functions
```csharp
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
 * @param param             Buffer to copy the parameters received.
 * @param paramlen          Maximum size of the parameters buffer.
 * @param delay             Delay of the output
 * @param once              True if the output has 'Only Once' flag enabled.
 * @return                  True if the output has been returned.
 */
bool GetEntityOutput(int entity, int index, char[] output, int outputlen, char[] target, int targetlen, char[] input, int inputlen, char[] param, int paramlen, float& delay, bool& once);

/**
 * Returns the entity outputs count.
 *
 * @param entity            Entity index.
 * @return                  The entity outputs count.
 */
int GetEntityOutputsCount(int entity);
```

# Examples
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
