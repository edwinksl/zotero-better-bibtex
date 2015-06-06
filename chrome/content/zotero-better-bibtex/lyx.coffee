# Credits:
# - small bits were borrowed from Lytero by Demetrio Girardi, lytero@dementrioatgmail.com

# Todo:
# * grab current set of bibliographies from current document. Cache file change data + bibs. Needs change in Lyx, or
#   grab current document name and scan that from the filesystem
# * make sure the bib is an auto-exported one
# * add citation sent to lyx doc to auto-exported collection

Zotero.Lyz =
  init: ->
    #set up preferences
    @prefs = Components.classes['@mozilla.org/preferences-service;1'].getService(Components.interfaces.nsIPrefService)
    @prefs = @prefs.getBranch('extensions.lyz.')

    runtime = Components.classes['@mozilla.org/xre/app-info;1'] .getService(Components.interfaces.nsIXULRuntime)
    @os = switch runtime.OS.downcase
      when 'winnt' then 'Windows'
      when 'linux', 'darwin', 'sunos', 'freebsd', 'openbsd', 'netbsd', 'irix64', 'aix', 'hp-ux' then 'Unix'
      else (if navigator.platform.indexOf('Win') == 0 then 'Windows' else 'Unix')

    @askServer = @askServer[@os]
    @pipeWriteAndRead = @pipeWriteAndRead[@os]

  getDoc: ->
    doc = @askServer('server-get-filename')
    if !doc
      @flash("Could not contact server at: #{@prefs.get('lyxserver')}")
      return null

    fname = /.*INFO:betterbibtex:server-get-filename:(.*)\n/.exec(res)
    if !fname
      @flash("ERROR: lyxGetDoc: \n\n#{doc}")
      return null
    return fname[1]

  getPos: ->
    res = @askServer('server-get-xy')
    xy = /INFO:betterbibtex:server-get-xy:(.*)/.exec(res)?[1]
    return xy

  pipeInit: ->
    # reading from lyxpipe.out
    win = @wm.getMostRecentWindow('navigator:browser')
    pipeout = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
    path = @prefs.getCharPref('lyxserver')
    pipeout.initWithPath path + '.out'
    if !pipeout.exists()
      @flash('The specified LyXServer pipe does not exist.')
      return null
    pipeout_stream = Components.classes['@mozilla.org/network/file-input-stream;1'].createInstance(Components.interfaces.nsIFileInputStream)
    cstream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].createInstance(Components.interfaces.nsIConverterInputStream)
    pipeout_stream.init pipeout, -1, 0, 0
    cstream.init pipeout_stream, 'UTF-8', 0, 0
    return cstream

  askServer: {
    Windows: (command) ->
      win = @wm.getMostRecentWindow('navigator:browser')
      try
        return @pipeWriteAndRead.Windows(command)
      catch x
        @flash("SERVER ERROR:\n#{x}")
        return false
      return true

    Unix: (command) ->
      win = @wm.getMostRecentWindow('navigator:browser')
      try
        cstream = @pipeInit()
      catch x
        @flash("SERVER ERROR:\n#{x}")
        return null
      try
        return @pipeWriteAndRead.Unix(command, cstream)
      catch x
        @flash("SERVER ERROR:\n#{x}")
        return null
      return true

  pipeWriteAndRead:
    Unix: (command, cstream) ->
      # Works in Linux 
      # writing to lyxpipe.in
      win = @wm.getMostRecentWindow('navigator:browser')
      try
        pipein = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
        pipein.initWithPath @prefs.getCharPref('lyxserver') + '.in'
      catch e
        @flash("Wrong path to Lyx server:\n#{@prefs.get('lyxserver')}\n#{e}")
        return false
      if !pipein.exists()
        @flash('Wrong path to Lyx server.\nSet the path specified in Lyx preferences.')
        return false
      try
        pipein_stream = Components.classes['@mozilla.org/network/file-output-stream;1'].createInstance(Components.interfaces.nsIFileOutputStream)
        pipein_stream.init pipein, 0x02 | 0x10, 0666, 0
        # write, append
      catch e
        @flash("Failed to:\n#{command}")
        return false
      msg = 'LYXCMD:betterbibtex:' + command + '\n'
      pipein_stream.write msg, msg.length
      pipein_stream.close()
      data = ''
      str = {}
      cstream.readString -1, str
      # read the whole file and put it in str.value
      data = str.value
      cstream.close()
      return data

    Windows: (command) ->
      win = @wm.getMostRecentWindow('navigator:browser')
      try
        pipein = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
        pipein.initWithPath @prefs.getCharPref('lyxserver') + '.in'
      catch e
        @flash("Wrong path to Lyx server:\n#{@prefs.get('lyxserver')}\n#{e}")
        return false
      if !pipein.exists()
        @flash('Wrong path to Lyx server.\nSet the path specified in Lyx preferences.')
        return false
      try
        pipein_stream = Components.classes['@mozilla.org/network/file-output-stream;1'].createInstance(Components.interfaces.nsIFileOutputStream)
        pipein_stream.init pipein, 0x02 | 0x10, 0666, 0
        # write, append
      catch e
        @flash("Failed to:\n#{command}")
        return false
      msg = 'LYXCMD:betterbibtex:' + command + '\n'
      pipein_stream.write msg, msg.length
      pipein_stream.close()
      data = ''
      str = {}
      # ----- open again
      pipeout = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
      path = @prefs.getCharPref('lyxserver')
      pipeout.initWithPath path + '.out'
      if !pipeout.exists()
        @flash('The specified LyXServer pipe does not exist.')
        return null
      pipeout_stream = Components.classes['@mozilla.org/network/file-input-stream;1'].createInstance(Components.interfaces.nsIFileInputStream)
      cstream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].createInstance(Components.interfaces.nsIConverterInputStream)
      pipeout_stream.init pipeout, -1, 0, 0
      cstream.init pipeout_stream, 'UTF-8', 0, 0
      cstream.readString -1, str
      # read the whole file and put it in str.value
      data = str.value
      cstream.close()
      return data

  checkAndCite: ->
    # export citation to Bibtex
    win = @wm.getMostRecentWindow('navigator:browser')
    zitems = win.ZoteroPane.getSelectedItems()

    # FIXME: this should be called below, but it returns empty there (???)
    if zitems.length == 0
      @flash('Please select at least one citation.')
      return

    # check document name
    [bib, doc] = @checkDocInDB()
    entries_text = ''
    if !bib
      t = 'Press OK to create new BibTeX database.\n'
      t += 'Press Cancel to select from your existing databases\n'
      # FIXME: the buttons don't show correctly, STD_YES_NO_BUTTONS doesn't work
      # var check = { value: true };
      # var ifps = Components.interfaces.nsIPromptService;
      # var promptService = Components.classes["@mozilla.org/embedcomp/prompt-service;1"].getService();
      # promptService = promptService.QueryInterface(ifps);
      # var res = confirm(t,"BibTex databse selection",
      # 		      ifps.STD_YES_NO_BUTTONS,null,null,null,"",check);
      res = win.confirm(t, 'BibTex database selection')
      if res
        bib_file = @dialog_FilePickerSave(win, 'Select Bibtex file for ' + doc, 'Bibtex', '*.bib')
        if !bib_file
          return
      else
        bib_file = @dialog_FilePickerOpen(win, 'Select Bibtex file for ' + doc, 'Bibtex', '*.bib')
        if !bib_file
          return
      bib = bib_file.path
      if bib_file
        @addNewDocument doc, bib
      else
        return
      #file dialog canceled
    items = @exportToBibtex(zitems, bib)
    keys = new Array
    zids = new Array
    for zid of items
      citekey = items[zid][0]
      text = items[zid][1]
      keys.push citekey
      #check database, if not in, append to entries_text
      #single key can be associated with several bibtex files
      res = @DB.query('SELECT key FROM keys WHERE bib=? AND zid=?', [
        bib
        zid
      ])
      if !res
        @DB.query 'INSERT INTO keys VALUES(null,?,?,?)', [
          citekey
          bib
          zid
        ]
        zids.push zid
        entries_text += text
      else if res[0]['key'] != citekey
        ask = win.confirm('Zotero record has been changed.\n' + 'Press OK to run \'Update BibTeX\' and insert the citation.\n' + 'Press Cancel to refrain from any action.', 'Zotero record changed!')
        if ask
          # FIXME: started to act weird
          xy = @lyxGetPos()
          @updateBibtexAll()
          @askServer 'server-set-xy:' + xy
        else
          return
    if !entries_text == ''
      @writeBib bib, entries_text, zids
    res = @askServer('citation-insert:' + keys.join(','))

  exportToBibliography: (item) ->
    win = @wm.getMostRecentWindow('navigator:browser')
    format = 'bibliography=http://www.zotero.org/styles/chicago-author-date'
    biblio = Zotero.QuickCopy.getContentFromItems([ item ], format)
    return biblio.text

  exportToBibtex: (items, bib, zids) ->
    # returns hash {id:[citekey,text]}
    win = @wm.getMostRecentWindow('navigator:browser')

    callback = (obj, worked) ->
      # FIXME: the Zotero API has changed from obj.output
      text = obj.string
      #.replace(/\r\n/g, "\n");// this is for Zotero 2.1
      if !text
        # this is for Zotero 2.0.9
        text = obj.output.replace(/\r\n/g, '\n')
      return

    translation = new Zotero.Translate.Export()
    translatorID = @prefs.getCharPref('selectedTranslator')
    translation.setTranslator translatorID
    translation.setHandler 'done', callback
    if @prefs.getBoolPref('use_utf8')
      translation.setDisplayOptions 'exportCharset': 'UTF-8'
    else
      translation.setDisplayOptions 'exportCharset': 'escape'
    if @prefs.getBoolPref('useJournalAbbreviation')
      translation.setDisplayOptions 'useJournalAbbreviation': 'True'
    tmp = new Array
    i = 0
    while i < items.length
      id = Zotero.Items.getLibraryKeyHash(items[i])
      translation.setItems [ items[i] ]
      translation.translate()
      itemOK = true
      if @prefs.getBoolPref('createCiteKey') == true
        # Workaround entries that have been deleted and added again to Zotero, which means they will have 
        # new zotero id and we can't identify them. 
        try
          ct = @createCiteKey(id, text, bib, items[i].key)
        catch e
          res = @DB.query('SELECT key FROM keys WHERE zid=?', [ zids[i] ])
          @flash('There is problem with one the entries:\nZotero ID: ' + zids[i] + '\nBibTeX Key: ' + res[0]['key'] + '\nThis item will be deleted from Lyz database because it has been removed from Zotero.\n' + 'You might have had duplicate items or you added same item after you have deleted from Zotero.\n\n' + 'If you are able to identify the item by the BibTeX key, please cite it again after the Update has finished.\n' + 'If you are unable to identify the item by the BibTeX key, you have to identify it in LyX document and cite it again.')
          @DB.query 'DELETE FROM keys WHERE zid=?', [ zids[i] ]
          itemOK = false
      else
        ckre = /.*@[a-z]+\{([^,]+),{1}/
        key = ckre.exec(text)[1]
        ct = [ key, text ]
      if itemOK
        tmp[id] = [ ct[0], ct[1] ]
      i++
    return tmp

  syncBibtexKeyFormat: (doc, oldkeys, newkeys) ->
    win = @wm.getMostRecentWindow('navigator:browser')
    #this.lyxPipeWrite("buffer-write");
    #this.lyxPipeWrite("buffer-close");	    
    lyxfile = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
    # LyX returns linux style paths, which don't work on Windows
    oldpath = doc
    try
      lyxfile.initWithPath doc
    catch e
      doc = doc.replace(/\//g, '\\')
      lyxfile.initWithPath doc
    if !lyxfile.exists()
      @flash('The specified ' + doc + ' does not exist.')
      return
    #remove old backup file
    try
      tmpfile = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
      tmpfile.initWithPath doc + '.lyz~'
      if tmpfile.exists()
        tmpfile.remove 1
    catch e
      @flash('Please report the following error:\n' + e)
      return
    # make new backup
    lyxfile.copyTo null, lyxfile.leafName + '.lyz~'
    # that main procedure
    @flash('Updating ' + doc)
    try
      cstream = @fileReadByLine(doc + '.lyz~')
      outstream = @fileWrite(doc)[1]
      line = {}
      lines = []
      re = /key\s\"([^\"].*)\"/
      loop
        hasmore = cstream.readLine(line)
        tmp = line.value
        if tmp.search('key') == 0
          tmpkeys = re.exec(tmp)[1].split(',')
          i = 0
          while i < tmpkeys.length
            o = tmpkeys[i]
            n = newkeys[oldkeys[tmpkeys[i]]]
            # user can have citations from alternative bibtex file
            # ignore those
            if n != undefined
              tmp = tmp.replace(o, n)
            i++
        outstream.writeString tmp + '\n'
        unless hasmore
          break
      cstream.close()
    catch e
      @flash('Please report the following error:\n' + e)
      oldfile = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
      oldfile.initWithPath doc
      if oldfile.exists()
        oldfile.remove 1
      # make new backup
      tmpfile.copyTo null, lyxfile.leafName
    #this.lyxPipeWrite("file-open:"+oldpath);	
    return

  fileReadByLine: (path) ->
    file = Components.classes['@mozilla.org/file/local;1'].createInstance(Components.interfaces.nsILocalFile)
    file.initWithPath path
    if !file.exists()
      @flash 'File ' + path + ' does not exist.'
      return
    file_stream = Components.classes['@mozilla.org/network/file-input-stream;1'].createInstance(Components.interfaces.nsIFileInputStream)
    cstream = Components.classes['@mozilla.org/intl/converter-input-stream;1'].createInstance(Components.interfaces.nsIConverterInputStream)
    file_stream.init file, -1, 0, 0
    cstream.init file_stream, 'UTF-8', 1024, 0xFFFD
    cstream.QueryInterface Components.interfaces.nsIUnicharLineInputStream
    return cstream

