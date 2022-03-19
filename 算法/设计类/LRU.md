### LRU缓存

+ 力扣：[面试题 16.25. LRU 缓存](https://leetcode-cn.com/problems/lru-cache-lcci/)

  ```
  运用你所掌握的数据结构，设计和实现一个  LRU (最近最少使用) 缓存机制 。
  实现 LRUCache 类：
  
  LRUCache(int capacity) 以正整数作为容量 capacity 初始化 LRU 缓存
  int get(int key) 如果关键字 key 存在于缓存中，则返回关键字的值，否则返回 -1 。
  void put(int key, int value) 如果关键字已经存在，则变更其数据值；如果关键字不存在，则插入该组「关键字-值」。当缓存容量达到上限时，它应该在写入新数据之前删除最久未使用的数据值，从而为新的数据值留出空间。
  进阶：你是否可以在 O(1) 时间复杂度内完成这两种操作？
  
  LRUCache cache = new LRUCache( 2 /* 缓存容量 */ );
  
  cache.put(1, 1);
  cache.put(2, 2);
  cache.get(1);       // 返回  1
  cache.put(3, 3);    // 该操作会使得密钥 2 作废
  cache.get(2);       // 返回 -1 (未找到)
  cache.put(4, 4);    // 该操作会使得密钥 1 作废
  cache.get(1);       // 返回 -1 (未找到)
  cache.get(3);       // 返回  3
  cache.get(4);       // 返回  4
  ```

+ 题解：

  + 快速增加和删除。时间复杂度：O（1）
    + 自己手写一个双向链表（最热数据保存在头结点，最冷数据保存在尾节点）
    + 当有新数据插入时，则插入到头结点。容量超过时，删除尾节点
  + 快速查询。时间复杂度：O（1）
    + 用一个unordered_map保存。key为要查找的key，value为value所在的节点

  ```c++
  struct Node {
    Node* pre_node;
    Node* next_node;
    int val;	// 查询key对应的value
    int key;	// 删除节点的时候，需要删掉map上的数据。所以要保存key
    Node() : key(-1), val(-1), pre_node(nullptr), next_node(nullptr) {}
    Node(int key, int val, Node* pre_node = nullptr, Node* next_node = nullptr) {
      this->key = key;
      this->val = val;
      this->pre_node = pre_node;
      this->next_node = next_node;
    }
  };
  
  class LRUCache {
    Node* head;	// 头伪节点
    Node* tail;	// 尾伪节点
    unordered_map<int, Node*> key_map;	// 保存key和node映射关系
    int total_capacity;
    int cur_capacity;
  
   public:
    LRUCache(int capacity) {
      total_capacity = capacity;
      cur_capacity = 0;
      head = new Node();
      tail = new Node();
      head->next_node = tail;
      tail->pre_node = head;
    }
      
    ~LRUCache() {
      if (head != nullptr) {
        delete head;
        head = nullptr;
      }
      if (tail != nullptr) {
        delete tail;
        tail = nullptr;
      }
      for (auto& m : key_map) {
        delete m.second;
        m.second = nullptr;
      }
    }
  
    int get(int key) {
      // 不存在这个key返回-1
      if (key_map.find(key) == key_map.end()) {
        return -1;
      }
      // 查找到则将节点移到头结点
      Node* node = key_map[key];
      moveToHead(node);
      return node->val;
    }
  
    void put(int key, int value) {
      Node* node = nullptr;
      if (key_map.find(key) == key_map.end()) {
        // 没有找到，则新建。并且将节点作为头结点
        node = new Node(key, value);
        addToHead(node);
        key_map[key] = node;
      } else {
        // 找到了。更新数据，将节点移到头结点
        node = key_map[key];
        node->val = value;
        moveToHead(node);
      }
  
     	// 容量超过限定，则需要删除
      if (key_map.size() > total_capacity) {
        // 删除尾节点
        Node* del_node = removeTail();
        // 删除map上的数据
        key_map.erase(del_node->key);
        // 释放内存
        delete del_node;
      }
    }
  
    void removeNode(Node* cur_node) {
      // 处理当前节点的前驱和后继
      cur_node->pre_node->next_node = cur_node->next_node;
      cur_node->next_node->pre_node = cur_node->pre_node;
    }
  
    void addToHead(Node* cur_node) {
      // 当做新头结点
      cur_node->next_node = head->next_node;
      head->next_node->pre_node = cur_node;
      cur_node->pre_node = head;
      head->next_node = cur_node;
    }
  
    Node* removeTail() {
      Node* del_node = tail->pre_node;
      removeNode(del_node);
      return del_node;
    }
  
    void moveToHead(Node* cur_node) {
      // 处理当前节点的前驱和后继
      removeNode(cur_node);
  
      // 将当前节点移到节点头部
      addToHead(cur_node);
    }
  };
  ```
  
