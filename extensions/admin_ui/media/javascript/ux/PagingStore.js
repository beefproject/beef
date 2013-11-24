//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * PagingStore for Ext 3.2 - v0.5
 */
Ext.ns('Ext.ux.data');
Ext.ux.data.PagingStore = Ext.extend(Ext.data.Store, {
    add: function (records) {
        records = [].concat(records);
        if (records.length < 1) {
            return;
        }
        for (var i = 0, len = records.length; i < len; i++) {
            records[i].join(this);
        }
        var index = this.data.length;
        this.data.addAll(records);
        // *** add ***
        if (this.allData) {
            this.allData.addAll(records);
        }
        // *** end ***
        if (this.snapshot) {
            this.snapshot.addAll(records);
        }
        // *** add ***
        this.totalLength += records.length;
        // *** end ***
        this.fireEvent('add', this, records, index);
    },
    remove: function (record) {
        if (Ext.isArray(record)) {
            Ext.each(record, function (r) {
                this.remove(r);
            }, this);
            return;
        }
        // *** add ***
        if (this != record.store) {
            return;
        }
        record.join(null);
        // *** end ***
        var index = this.data.indexOf(record);
        if (index > -1) {
            // record.join(null);
            this.data.removeAt(index);
        }
        if (this.pruneModifiedRecords) {
            this.modified.remove(record);
        }
        // *** add ***
        if (this.allData) {
            this.allData.remove(record);
        }
        // *** end ***
        if (this.snapshot) {
            this.snapshot.remove(record);
        }
        // *** add ***
        this.totalLength--;
        // *** end ***
        if (index > -1) {
            this.fireEvent('remove', this, record, index);
        }
    },
    removeAll: function (silent) {
        // *** add ***
        var items = [].concat((this.snapshot || this.allData || this.data).items);
        // *** end ***
        // var items = [];
        // this.each(function (rec) {
        //     items.push(rec);
        // });
        this.clearData();
        // if (this.snapshot) {
        //     this.snapshot.clear();
        // }
        if (this.pruneModifiedRecords) {
            this.modified = [];
        }
        // *** add ***
        this.totalLength = 0;
        // *** end ***
        if (silent !== true) {
            this.fireEvent('clear', this, items);
        }
    },
    insert: function (index, records) {
        records = [].concat(records);
        for (var i = 0, len = records.length; i < len; i++) {
            this.data.insert(index, records[i]);
            records[i].join(this);
        }
        // *** add ***
        if (this.allData) {
            this.allData.addAll(records);
        }
        // *** end ***
        if (this.snapshot) {
            this.snapshot.addAll(records);
        }
        // *** add ***
        this.totalLength += records.length;
        // *** end ***
        this.fireEvent('add', this, records, index);
    },
    getById: function (id) {
        // *** add ***
        return (this.snapshot || this.allData || this.data).key(id);
        // *** end ***
        // return this.data.key(id);
    },
    clearData: function () {
        // *** add ***
        if (this.allData) {
            this.data = this.allData;
            delete this.allData;
        }
        if (this.snapshot) {
            this.data = this.snapshot;
            delete this.snapshot;
        }
        // *** end ***
        this.data.each(function (rec) {
            rec.join(null);
        });
        this.data.clear();
    },
    execute: function (action, rs, options, batch) {
        if (!Ext.data.Api.isAction(action)) {
            throw new Ext.data.Api.Error('execute', action);
        }
        options = Ext.applyIf(options || {}, {
            params: {}
        });
        if (batch !== undefined) {
            this.addToBatch(batch);
        }
        var doRequest = true;
        if (action === 'read') {
            doRequest = this.fireEvent('beforeload', this, options);
            Ext.applyIf(options.params, this.baseParams);
        }
        else {
            if (this.writer.listful === true && this.restful !== true) {
                rs = (Ext.isArray(rs)) ? rs : [rs];
            }
            else if (Ext.isArray(rs) && rs.length == 1) {
                rs = rs.shift();
            }
            if ((doRequest = this.fireEvent('beforewrite', this, action, rs, options)) !== false) {
                this.writer.apply(options.params, this.baseParams, action, rs);
            }
        }
        if (doRequest !== false) {
            if (this.writer && this.proxy.url && !this.proxy.restful && !Ext.data.Api.hasUniqueUrl(this.proxy, action)) {
                options.params.xaction = action;
            }
            // *** add ***
            if (action === "read" && this.isPaging(Ext.apply({}, options.params))) {
                (function () {
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
            // *** end ***
            this.proxy.request(Ext.data.Api.actions[action], rs, options.params, this.reader, this.createCallback(action, rs, batch), this, options);
        }
        return doRequest;
    },
    loadRecords: function (o, options, success) {
        if (this.isDestroyed === true) {
            return;
        }
        if (!o || success === false) {
            if (success !== false) {
                this.fireEvent('load', this, [], options);
            }
            if (options.callback) {
                options.callback.call(options.scope || this, [], options, false, o);
            }
            return;
        }
        var r = o.records,
            t = o.totalRecords || r.length;
        if (!options || options.add !== true) {
            if (this.pruneModifiedRecords) {
                this.modified = [];
            }
            for (var i = 0, len = r.length; i < len; i++) {
                r[i].join(this);
            }
            //if (this.snapshot) {
            //    this.data = this.snapshot;
            //    delete this.snapshot;
            //}
            this.clearData();
            this.data.addAll(r);
            this.totalLength = t;
            this.applySort();
            // *** add ***
            if (!this.allData) {
                this.applyPaging();
            }
            if (r.length > this.getCount()) {
                r = [].concat(this.data.items);
            }
            // *** end ***
            this.fireEvent('datachanged', this);
        } else {
            this.totalLength = Math.max(t, this.data.length + r.length);
            this.add(r);
        }
        this.fireEvent('load', this, r, options);
        if (options.callback) {
            options.callback.call(options.scope || this, r, options, true);
        }
    },
    loadData: function (o, append) {
        // *** add ***
        this.isPaging(Ext.apply({}, this.lastOptions ? this.lastOptions.params : null, this.baseParams));
        // *** end ***
        var r = this.reader.readRecords(o);
        this.loadRecords(r, {
            add: append
        }, true);
    },
    getTotalCount: function () {
        // *** add ***
        if (this.allData) {
            return this.allData.getCount();
        }
        // *** end ***
        return this.totalLength || 0;
    },
    sortData: function () {
        var sortInfo = this.hasMultiSort ? this.multiSortInfo : this.sortInfo,
            direction = sortInfo.direction || "ASC",
            sorters = sortInfo.sorters,
            sortFns = [];
        if (!this.hasMultiSort) {
            sorters = [{
                direction: direction,
                field: sortInfo.field
            }];
        }
        for (var i = 0, j = sorters.length; i < j; i++) {
            sortFns.push(this.createSortFunction(sorters[i].field, sorters[i].direction));
        }
        if (!sortFns.length) {
            return;
        }
        var directionModifier = direction.toUpperCase() == "DESC" ? -1 : 1;
        var fn = function (r1, r2) {
            var result = sortFns[0].call(this, r1, r2);
            if (sortFns.length > 1) {
                for (var i = 1, j = sortFns.length; i < j; i++) {
                    result = result || sortFns[i].call(this, r1, r2);
                }
            }
            return directionModifier * result;
        };
        // *** add ***
        if (this.allData) {
            this.data = this.allData;
            delete this.allData;
        }
        // *** end ***
        this.data.sort(direction, fn);
        if (this.snapshot && this.snapshot != this.data) {
            this.snapshot.sort(direction, fn);
        }
        // *** add ***
        this.applyPaging();
        // *** end ***
    },
    filterBy: function (fn, scope) {
        // *** add ***
        this.snapshot = this.snapshot || this.allData || this.data;
        // *** end ***
        // this.snapshot = this.snapshot || this.data;
        this.data = this.queryBy(fn, scope || this);
        // *** add ***
        this.applyPaging();
        // *** end ***
        this.fireEvent('datachanged', this);
    },
    clearFilter: function (suppressEvent) {
        if (this.isFiltered()) {
            this.data = this.snapshot;
            delete this.snapshot;
            // *** add ***
            delete this.allData;
            this.applyPaging();
            // *** end ***
            if (suppressEvent !== true) {
                this.fireEvent('datachanged', this);
            }
        }
    },
    isFiltered: function () {
        // *** add ***
        return !!this.snapshot && this.snapshot != (this.allData || this.data);
        // *** end ***
        // return !!this.snapshot && this.snapshot != this.data;
    },
    queryBy: function (fn, scope) {
        // *** add ***
        var data = this.snapshot || this.allData || this.data;
        // *** end ***
        // var data = this.snapshot || this.data;
        return data.filterBy(fn, scope || this);
    },
    collect: function (dataIndex, allowNull, bypassFilter) {
        // *** add ***
        var d = (bypassFilter === true ? this.snapshot || this.allData || this.data : this.data).items;
        // *** end ***
        // var d = (bypassFilter === true && this.snapshot) ? this.snapshot.items : this.data.items;
        var v, sv, r = [],
            l = {};
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
    findInsertIndex : function(record){
        this.suspendEvents();
        var data = this.data.clone();
        this.data.add(record);
        this.applySort();
        var index = this.data.indexOf(record);
        this.data = data;
        // *** add ***
        this.totalLength--;
        // *** end ***
        this.resumeEvents();
        return index;
    },
    // *** add ***
    isPaging: function (params) {
        var pn = this.paramNames,
            start = params[pn.start],
            limit = params[pn.limit];
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
    applyPaging: function () {
        var start = this.start,
            limit = this.limit;
        if ((typeof start == 'number') && (typeof limit == 'number')) {
            var allData = this.data,
                data = new Ext.util.MixedCollection(allData.allowFunctions, allData.getKey);
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
    // *** end ***
});

Ext.ux.data.PagingDirectStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: Ext.data.DirectStore.prototype.constructor
});
Ext.reg('pagingdirectstore', Ext.ux.data.PagingDirectStore);

Ext.ux.data.PagingJsonStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: Ext.data.JsonStore.prototype.constructor
});
Ext.reg('pagingjsonstore', Ext.ux.data.PagingJsonStore);

Ext.ux.data.PagingXmlStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: Ext.data.XmlStore.prototype.constructor
});
Ext.reg('pagingxmlstore', Ext.ux.data.PagingXmlStore);

Ext.ux.data.PagingArrayStore = Ext.extend(Ext.ux.data.PagingStore, {
    constructor: Ext.data.ArrayStore.prototype.constructor,
    loadData: function (data, append) {
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

Ext.ux.data.PagingGroupingStore = Ext.extend(Ext.ux.data.PagingStore, Ext.copyTo({}, Ext.data.GroupingStore.prototype, [
    'constructor',
    'remoteGroup',
    'groupOnSort',
    'groupDir',
    'clearGrouping',
    'groupBy',
    'sort',
    'applyGroupField',
    'applyGrouping',
    'getGroupState'
]));
Ext.reg('paginggroupingstore', Ext.ux.data.PagingGroupingStore);

Ext.ux.PagingToolbar = Ext.extend(Ext.PagingToolbar, {
    onLoad: function (store, r, o) {
        if (!this.rendered) {
            this.dsLoaded = [store, r, o];
            return;
        }
        var p = this.getParams();
        this.cursor = (o.params && o.params[p.start]) ? o.params[p.start] : 0;
        this.onChange();
        // *** end ***
        // var d = this.getPageData(),
        //     ap = d.activePage,
        //     ps = d.pages;
        // this.afterTextItem.setText(String.format(this.afterPageText, d.pages));
        // this.inputItem.setValue(ap);
        // this.first.setDisabled(ap == 1);
        // this.prev.setDisabled(ap == 1);
        // this.next.setDisabled(ap == ps);
        // this.last.setDisabled(ap == ps);
        // this.refresh.enable();
        // this.updateInfo();
        // this.fireEvent('change', this, d);
    },
    onChange: function () {
        // *** add ***
        var t = this.store.getTotalCount(),
            s = this.pageSize;
        if (this.cursor >= t) {
            this.cursor = Math.ceil((t + 1) / s) * s;
        }
        // *** end ***
        var d = this.getPageData(),
            ap = d.activePage,
            ps = d.pages;
        this.afterTextItem.setText(String.format(this.afterPageText, d.pages));
        this.inputItem.setValue(ap);
        this.first.setDisabled(ap == 1);
        this.prev.setDisabled(ap == 1);
        this.next.setDisabled(ap == ps);
        this.last.setDisabled(ap == ps);
        this.refresh.enable();
        this.updateInfo();
        this.fireEvent('change', this, d);
    },
    onClear: function () {
        this.cursor = 0;
        this.onChange();
    },
    doRefresh: function () {
        // *** add ***
        delete this.store.lastParams;
        // *** end ***
        this.doLoad(this.cursor);
    },
    bindStore: function (store, initial) {
        var doLoad;
        if (!initial && this.store) {
            if (store !== this.store && this.store.autoDestroy) {
                this.store.destroy();
            } else {
                this.store.un('beforeload', this.beforeLoad, this);
                this.store.un('load', this.onLoad, this);
                this.store.un('exception', this.onLoadError, this);
                // *** add ***
                this.store.un('datachanged', this.onChange, this);
                this.store.un('add', this.onChange, this);
                this.store.un('remove', this.onChange, this);
                this.store.un('clear', this.onClear, this);
                // *** end ***
            }
            if (!store) {
                this.store = null;
            }
        }
        if (store) {
            store = Ext.StoreMgr.lookup(store);
            store.on({
                scope: this,
                beforeload: this.beforeLoad,
                load: this.onLoad,
                exception: this.onLoadError,
                // *** add ***
                datachanged: this.onChange,
                add: this.onChange,
                remove: this.onChange,
                clear: this.onClear
                // *** end ***
            });
            doLoad = true;
        }
        this.store = store;
        if (doLoad) {
            this.onLoad(store, null, {});
        }
    }
});
Ext.reg('ux.paging', Ext.ux.PagingToolbar);
