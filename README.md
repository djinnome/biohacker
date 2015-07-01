
```
Automatically exported from code.google.com/p/biohacker
```

_Mistakes are the portals of discovery._ James Joyce (1882-1941)


A metabolic network of an organism is defined as a set of all biochemical reactions catalyzed by the enzymes encoded in its genome.  During the reconstuction of an organism's metabolic network, several kinds of inference problems can arise:  
  * Inferring instance reactions from generic reactions
    * e.g. `An alcohol + NAD+ --> an aldehyde + NADH` is instantiated to `ethanol + NAD+ --> acetaldehyde + NADH`
  * Inferring missing reactions and transporters from experimentally observed phenotypes
    * e.g. Metabolic network is unable to produce essential compounds necessary for growth from a known minimal nutrient media
  * Inferring reactions to remove based on experimentally observed phenotypes.
    * e.g. Metabolic network can produce all compounds sufficient for growth even after the removal of an essential gene
Because of these issues, manually reconstructing metabolic networks from annotated genomes is currently a time-consuming, error-prone process.

We develop `BioHacker`, a debugger for metabolic networks. `BioHacker` not only detects these issues, but also generates explanations as to where the problems lie and generates hypotheses for how to fix them.

  * Read the [BioHacker paper (PDF)](http://biohacker.googlecode.com/svn/docs/biohacker.pdf).
  * Check out the [source code](http://code.google.com/p/biohacker/source/list).

