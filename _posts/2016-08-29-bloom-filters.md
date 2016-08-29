---
layout: post
title: Trie vs. Murmurhash
---

A trend I see in blogs and Stack Overflows and all the rest is explaining CS concepts to those who might have rushed past a CS background -- sorting algorithms, traditional CS logic problems, etc. These concepts have their practical applications, but modern-day coding magic sometimes hide them from view. Tries are no exception; until a few weeks ago, I thought they were a side effect of bad English-language instruction.

![](https://upload.wikimedia.org/wikipedia/commons/e/eb/Ash_Tree_-_geograph.org.uk_-_590710.jpg)
*I got to states in the National Spelling Bee once. I lost on "speleology". Now I'll always know how to spell speleology. Also, in finding this picture, I learned there are 3.04 trillion trees on Earth -- about 400 per human. We cut down about 15 billion a year which is a bummer.*

Tries are a type of data tree, but not all trees are tries. You've probably come across basic binary trees before. We've covered them in discussions of search functions -- there's a root, branches one travels down, and nodes that have at most two children. They're recursive and boolean, two types of reasoning that computers just love (and why do computers love these things? Binary, duh)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Binary_tree.svg/192px-Binary_tree.svg.png)
*This is Wikipedia's default image for its binary tree article, and it's not balanced and not sorted and it drives me crazy that this is the case.*

Hash tables are considered to be superior to trees performance-wise in many cases. Part of the reason for this is that the performance of hash tables don't usually depend on the size of the hash (since each key-value lookup performs independently) but there's also always the chance that hash collisions can happen, or that our data is not particularly discrete, and thus limiting ourselves to one key-value pair can be quite limiting if we're not sure what we're initially looking for.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Hash_table_5_0_1_1_1_1_1_LL.svg/450px-Hash_table_5_0_1_1_1_1_1_LL.svg.png)
*Data collisions are talked about so much in discussions of hashes because of the birthday problem. Even if you only have twenty-odd entries and a table of 360 buckets, you still have a 50% chance of a collision! Statistics are crazy!*

So in cases where outcome is fairly flexible and dynamic, tries are your dudes. A trie, in essence, is just a tree that uses its parents as dependencies for the final product (quite good for string lookups!)

![](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Pointer_implementation_of_a_trie.svg/393px-Pointer_implementation_of_a_trie.svg.png)

But I also found a lot of pushback to the concept. It seemed as though hash tables are, quite often, faster. So I looked more deeply into exactly what kind of hash function Ruby uses. The latest information I could find implied that Ruby utilizes Murmurhash, which rotates and multiplies data, to keep a pseudo-random distribution.

Murmurhash looks like this:

```
#define ROT32(x, y) ((x << y) | (x >> (32 - y))) // avoid effort
uint32_t murmur3_32(const char *key, uint32_t len, uint32_t seed) {
	static const uint32_t c1 = 0xcc9e2d51;
	static const uint32_t c2 = 0x1b873593;
	static const uint32_t r1 = 15;
	static const uint32_t r2 = 13;
	static const uint32_t m = 5;
	static const uint32_t n = 0xe6546b64;

	uint32_t hash = seed;

	const int nblocks = len / 4;
	const uint32_t *blocks = (const uint32_t *) key;
	int i;
	uint32_t k;
	for (i = 0; i < nblocks; i++) {
		k = blocks[i];
		k *= c1;
		k = ROT32(k, r1);
		k *= c2;

		hash ^= k;
		hash = ROT32(hash, r2) * m + n;
	}

	const uint8_t *tail = (const uint8_t *) (key + nblocks * 4);
	uint32_t k1 = 0;

	switch (len & 3) {
	case 3:
		k1 ^= tail[2] << 16;
	case 2:
		k1 ^= tail[1] << 8;
	case 1:
		k1 ^= tail[0];

		k1 *= c1;
		k1 = ROT32(k1, r1);
		k1 *= c2;
		hash ^= k1;
	}

	hash ^= len;
	hash ^= (hash >> 16);
	hash *= 0x85ebca6b;
	hash ^= (hash >> 13);
	hash *= 0xc2b2ae35;
	hash ^= (hash >> 16);

	return hash;
}
```
Murmurhash guarantees that there will be no data collision for bytes under 4 characters (because it offers that many possibilities of uniqueness). A typical ASCII character has 1 byte, and the highest number of bytes allowed by UTF-8 is 4 bytes. It's also worth noting that about 40% of hashes ever created in Ruby will never use more than one bucket for its data, since many people will use small hashes in their applications.

This means that you're liable to run into data collisions above that, and many words tend to be above four characters. This is where the speed of tries shines -- while the initial lookup time cost of hash functions are, optimally, smaller, remember that a trie is looking at smaller and smaller collections of characters, offering the possibility of greater speed and precision.

It all really depends on your data. If you, like me, just want to look at words, tries are a little tempting because their size is never much more than the dictionary they're translating, and logistically they're a little simpler to think about (and why bother with cryptography with certain things that don't need to be cryptographed)?
