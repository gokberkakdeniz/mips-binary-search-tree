# mips-binary-search-tree

![main menu](/images/menu.prg)

Binary Search Tree insert, build, level-order print, and find operation implementations with a menu in MIPS.

## Implementation Details

| Byte Address | Contents                   |
| ------------ | -------------------------- |
| X            | Value of the node          |
| X + 4        | Address of the left child  |
| X + 8        | Address of the right child |
| X + 12       | Address of the parent      |

### `build(list: &int[], tree: &node): void`

This procedure calls insert procedure for each element in the list.

### `insert(value: int, tree: &node): &node`

This procedure recalls itself with corresponding child as second argument until the argument tree’s
corresponding child is empty. Once the recursion end, it dynamically allocate space for new node. It
also skips duplicate value insertion.
Also it updates height of tree to solve problem in print procedure.

### `find(value: int, tree: &node): (1) | (0, &node)`

This procedure is slightly modified version of insert procedure. It recalls itself until the value found
or tree has no child. Once the value is found, it returns (0, address of the node), otherwise (1).

### `print(tree: &node)`

This procedure prints tree in level order. Level order traversal is nothing but Breath First Search. To
implement BFS with queue, I wrote dequeue procedure. This procedure returns topmost element in
the stack pointer and moves all inserted elements one cell upper and deallocate a cell in $sp.
To achieve newline printing, after end of each level, I enqueued new line indicator address 1. I
choose this number since address 0 is choosen as no child indicator. Since the root level and that
indicator are manually enqueued, the loop first detects root node, then it enqueues left and right
node, then it detects new line indicator and pushes again new line indicator...
Another challinging part was printing missing empty nodes. I checked if the child is empty. If child
is empty enqueued a fake leaf node with value -9999. The value -9999 is choosen because it is
known not to be inserted in homework specification. Therefore it can successfully represent a fake
node.
Although it seems to be done, it causes infinite recursion with classical approach since the loop runs
until no element exist in a queue. To prevent this, I limit the loop iteration height times.
To discriminate seperators dash “-” and whitespace “ ”, I increased after counter after each node
printing and reset it after end of level. If the counter is odd number, dash is printed, otherwise
whitespace is printed. This process is skipped if it is first level.
