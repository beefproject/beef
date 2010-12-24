/*
 * PagingStore for Ext 3 - v0.4.1
 */
Ext.ns('Ext.ux.data');
Ext.ux.data.PagingStore = Ext.extend(Ext.data.Store, {
    destroy: function() {
        if (this.storeId) {
            Ext.StoreMgr.unregister(this);
        }
        this.data = this.allData = this.snapshot = null;
        Ext.destroy(this.proxy);
        this.reader = this.writer = null;
        this.purgeListeners();
    },
    add: function(records) {
        records = [].concat(records);
        if (records.length < 1) {
            return;
        }
        for (var i = 0, len = records.length; i < len; i++) {
            records[i].join(this);
        }
        var index = this.data.length;
        this.data.addAll(records);
        if (this.allData) {
            this.allData.addAll(records);
        }
        if (this.snapshot) {
            this.snapshot.addAll(records);
        }
        this.fireEvent("add", this, records, index);
    },
    remove: function(record) {
        var index = this.data.indexOf(record);
        if(index > -1){
            this.data.removeAt(index);
        }
        if (this.allData) {
            this.allData.remove(record);
        }
        if (this.snapshot) {
            this.snapshot.remove(record);
        }
        if (this.pruneModifiedRecords) {
            this.modified.remove(record);
        }
        if(index > -1){
            this.fireEvent("remove", this, record, index);
        }
    },
    removeAll: function() {
        this.data.clear();
        if (this.allData) {
            this.allData.clear();
        }
        if (this.snapshot) {
            this.snapshot.clear();
        }
        if (this.pruneModifiedRecords) {
            this.modified = [];
        }
        this.fireEvent("clear", this);
    },
    insert: function(index, records) {
        records = [].concat(records);
        for (var i = 0, len = records.length; i < len; i++) {
            this.data.insert(index, records[i]);
            records[i].join(this);
        }
        if (this.allData) {
            this.allData.addAll(records);
        }
        if (this.snapshot) {
            this.snapshot.addAll(records);
        }
        this.fireEvent("add", this, records, index);
    },
    getById: function(id) {
        return (this.snapshot || this.allData || this.data).key(id);
    },
    execute: function(action, rs, options) {
        if (!Ext.data.Api.isAction(action)) {
            throw new Ext.data.Api.Error('execute', action);
        }
        options = Ext.applyIf(options || {}, {params: {}});
        var doRequest = true;
        if (action === "read") {
            doRequest = this.fireEvent('beforeload', this, options);
        }
        else {
            if (this.writer.listful === true && this.restful !== true) {
                rs = (Ext.isArray(rs)) ? rs: [rs];
            }
            else if (Ext.isArray(rs) && rs.length == 1) {
                rs = rs.shift();
            }
            if ((doRequest = this.fireEvent('beforewrite', this, action, rs, options)) !== false) {
                this.writer.write(action, options.params, rs);
            }
        }
        if (doRequest !== false) {
            //var params = Ext.apply(options.params || {}, this.baseParams);
            var params = Ext.apply({}, options.params, this.baseParams);
            if (this.writer && this.proxy.url && !this.proxy.restful && !Ext.data.Api.hasUniqueUrl(this.proxy, action)) {
                params.xaction = action;
            }
            if (action === "read" && this.isPaging(params)) {
                (function() {
                    if (this.allData) {
                        this.data = this.allData;
                        delete this.allData;
                    }
                    this.applyPaging();
                    this.fireEvent("datachanged", this);
                    var r = [].concat(this.data.items);
                    this.fireEvent("load", this, r, options);
                    if (options.callback) {
                        options.callback.call(options.scope || this, r, options, true);
                    }
                }).defer(1, this);
                return true;
            }
            this.proxy.request(Ext.data.Api.actions[action], rs, params, this.reader, this.createCallback(action, rs), this, options);
        }
        return doRequest;
    },
    loadRecords: function(o, options, success) {
        if (!o || success === false) {
            if (success !== false) {
                this.fireEvent("load", this, [], options);
            }
            if (options.callback) {
                options.callback.call(options.scope || this, [], options, false, o);
            }
            return;
        }
        var r = o.records, t = o.totalRecords || r.length;
        if (!options || options.add !== true) {
            if (this.pruneModifiedRecords) {
                this.modified = [];
            }
            for (var i = 0, len = r.length; i < len; i++) {
                r[i].join(this);
            }
            if (this.allData) {
                this.data = this.allData;
                delete this.allData;
            }
            if (this.snapshot) {
                this.data = this.snapshot;
                delete this.snapshot;
            }
            this.data.clear();
            this.data.addAll(r);
            this.totalLength = t;
            this.applySort();
            if (!this.allData) {
                this.applyPaging();
            }
            if (r.length != this.getCount()) {
                r = [].concat(this.data.items);
            }
            this.fireEvent("datachanged", this);
        } else {
            this.totalLength = Math.max(t, this.data.length + r.length);
            this.add(r);
        }
        this.fireEvent("load", this, r, options);
        if (options.callback) {
            options.callback.call(options.scope || this, r, options, true);
        }
    },
    loadData: function(o, append) {
        this.isPaging(Ext.apply({}, this.lastOptions ? this.lastOptions.params : null, this.baseParams));
        var r = this.reader.readRecords(o);
        this.loadRecords(r, {add: append}, true);
    },
    getTotalCount: function() {
        return this.allData ? this.allData.getCount() : this.totalLength || 0;
    },
    sortData: function(f, direction) {
        direction = direction || 'ASC';
        var st = this.fields.get(f).sortType;
        var fn = function(r1, r2) {
            var v1 = st(r1.data[f]), v2 = st(r2.data[f]);
            return v1 > v2 ? 1 : (v1 < v2 ? -1 : 0);
        };
        if (this.allData) {
            this.data = this.allData;
            delete this.allData;
        }
        this.data.sort(direction, fn);
        if (this.snapshot && this.snapshot != this.data) {
            this.snapshot.sort(direction, fn);
        }
        this.applyPaging();
    },
    filterBy: function(fn, scope) {
        this.snapshot = this.snapshot || this.allData || this.data;
        delete this.allData;
        this.data = this.queryBy(fn, scope || this);
        this.applyPaging();
        this.fireEvent("datachanged", this);
    },
    queryBy: function(fn, scope) {
        var data = this.snapshot || this.allData || this.data;
        return data.filterBy(fn, scope || this);
    },
    collect: function(dataIndex, allowNull, bypassFilter) {
        var d = (bypassFilter === true ? this.snapshot || this.allData || this.data: this.data).items;
        var v, sv, r = [], l = {};
        for (var i = 0, len = d.length; i < len; i++) {
            v = d[i].data[dataIndex];
            sv = String(v);
            if ((allowNull || !Ext.isEmpty(v)) && !l[sv]) {
                l[sv] = true;
                r[r.length] = v;
            }
        }
        return r;
    },
    clearFilter: function(suppressEvent) {
        if (this.isFiltered()) {
            this.data = this.snapshot;
            delete this.allData;
            delete this.snapshot;
            this.applyPaging();
            if (suppressEvent !== true) {
                this.fireEvent("datachanged", this);
            }
        }
    },
    isFiltered: function() {
        return this.snapshot && this.snapshot != (this.allData || this.data);
    },
    isPaging: function(params) {
        var pn = this.paramNames, start = params[pn.start], limit = params[pn.limit];
        if ((typeof start != 'number') || (typeof limit != 'number')) {
            delete this.start;
            delete this.limit;
            this.lastParams = params;
            return false;
        }
        this.start = start;
        this.limit = limit;
        delete params[pn.start];
        delete params[pn.limit];
        var lastParams = this.lastParams;
        this.lastParams = params;
        if (!this.proxy) {
            return true;
        }
        if (!lastParams) {
            return false;
        }
        for (var param in params) {
            if (params.hasOwnProperty(param) && (params[param] !== lastParams[param])) {
                return false;
            }
        }
        for (param in lastParams) {
            if (lastParams.hasOwnProperty(param) && (params[param] !== lastParams[param])) {
                return false;
            }
        }
        return true;
    },
    applyPaging: function() {
        var start = this.start, limit = this.limit;
        if ((typeof start == 'number') && (typeof limit == 'number')) {
            var allData = this.data, data = new Ext.util.MixedCollection(allData.allowFunctions, allData.getKey);
            data.items = allData.items.slice(start, start + limit);
            data.keys = allData.keys.slice(start, start + limit);
            var len = data.length = data.items.length;
            var map = {};
            for (var i = 0; i < len; i++) {
                var item = data.items[i];
                map[data.getKey(item)] = item;
            }
            data.map = map;
            this.allData = allData;
            this.data = data;
        }
    }
});
Ext.ux.data.PagingDirectStore = function(c) {
    c.batchTransactions = false;
    Ext.ux.data.PagingDirectStore.superclass.constructor.call(this, Ext.apply(c, {
        proxy: (typeof(c.proxy) == 'undefined') ? new Ext.data.DirectProxy(Ext.copyTo({}, c, 'paramOrder,paramsAsHash,directFn,api')) : c.proxy,
        reader: (typeof(c.reader) == 'undefined' && typeof(c.fields) == 'object') ? new Ext.data.JsonReader(Ext.copyTo({}, c, 'totalProperty,root,idProperty'), c.fields) : c.reader
    }));
};
Ext.extend(Ext.ux.data.PagingDirectStore, Ext.ux.data.PagingStore, {});
Ext.reg('pagingdirectstore', Ext.ux.data.PagingDirectStore);
Ext.ux.data.PagingJsonStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: function(config) {
        Ext.ux.data.PagingJsonStore.superclass.constructor.call(this, Ext.apply(config, {
            reader: new Ext.data.JsonReader(config)
        }));
    }
});
Ext.reg('pagingjsonstore', Ext.ux.data.PagingJsonStore);
Ext.ux.data.PagingXmlStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: function(config) {
        Ext.ux.data.PagingXmlStore.superclass.constructor.call(this, Ext.apply(config, {
            reader: new Ext.data.XmlReader(config)
        }));
    }
});
Ext.reg('pagingxmlstore', Ext.ux.data.PagingXmlStore);
Ext.ux.data.PagingArrayStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: function(config) {
        Ext.ux.data.PagingArrayStore.superclass.constructor.call(this, Ext.apply(config, {
            reader: new Ext.data.ArrayReader(config)
        }));
    },
    loadData: function(data, append) {
        if (this.expandData === true) {
            var r = [];
            for (var i = 0, len = data.length; i < len; i++) {
                r[r.length] = [data[i]];
            }
            data = r;
        }
        Ext.ux.data.PagingArrayStore.superclass.loadData.call(this, data, append);
    }
});
Ext.reg('pagingarraystore', Ext.ux.data.PagingArrayStore);
Ext.ux.data.PagingSimpleStore = Ext.ux.data.PagingArrayStore;
Ext.reg('pagingsimplestore', Ext.ux.data.PagingSimpleStore);
