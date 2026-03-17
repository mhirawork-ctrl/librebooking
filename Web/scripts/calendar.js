function Calendar(opts) {
  var _options = opts;
  var _fullCalendar;
  var dateVar = null;

  var dayDialog = $('#dayDialog');

  var elements = {
    loadingIndicator: $('#loadingIndicator'),
    moveReservationForm: $('#moveReservationForm'),
    moveReferenceNumber: $('#moveReferenceNumber'),
    moveStartDate: $('#moveStartDate'),
    moveErrorOk: $('#moveErrorOk'),
    moveErrorDialog: $('#moveErrorDialog'),
    moveErrorsList: $('#moveErrorsList'),
  };

  Calendar.prototype.init = function () {
    function getSelectedFilterText() {
      var selectedText = $('#calendarFilter option:selected').text().trim();
      if (!_.isEmpty(selectedText)) {
        return selectedText;
      }

      var groupText = $('.groupName').first().text().trim();
      if (!_.isEmpty(groupText)) {
        return groupText;
      }

      return '全会議室';
    }

    function currentCalendarDate() {
      if (_fullCalendar) {
        return _fullCalendar.fullCalendar('getDate');
      }

      return _options.defaultDate;
    }

    function normalizedCurrentDate() {
      return moment(currentCalendarDate()).format('YYYY-M-D');
    }

    function escapeHtml(value) {
      return $('<div/>').text(value || '').html();
    }

    function plainTextReservationTitle(value) {
      if (_.isEmpty(value)) {
        return '';
      }

      var normalized = String(value)
        .replace(/<br\s*\/?>/gi, '\n')
        .replace(/<\/span>\s*<span[^>]*>/gi, '\n');
      var decoded = $('<div/>').html(normalized).text();

      return decoded.replace(/\s*\n\s*/g, ' / ').replace(/\s+/g, ' ').trim();
    }

    function currentViewTitle(view) {
      if (view && view.title) {
        return view.title;
      }

      return $('#calendar .fc-center h2').text().trim();
    }

    function buildViewRedirect(view) {
      var redirectDate = currentCalendarDate();

      if (view && view.start) {
        redirectDate = view.type == 'month' && view.currentRange ? view.currentRange.start : view.start;
      }

      return (
        _options.returnTo +
        encodeURIComponent(
          '?ct=' +
            (view ? view.name : _options.view) +
            '&start=' +
            redirectDate.year() +
            '-' +
            (redirectDate.month() + 1) +
            '-' +
            redirectDate.date()
        )
      );
    }

    function getEventHref(event, view) {
      if (_.isEmpty(event.id) || _.isEmpty(event.url)) {
        return '#';
      }

      return event.url.replace('[redirect]', buildViewRedirect(view));
    }

    function renderCalendarDigest(view) {
      var digestList = $('#calendarDigestList');

      if (digestList.length === 0) {
        return;
      }

      var digestEvents = _fullCalendar
        ? _fullCalendar.fullCalendar('clientEvents', function (event) {
            return !_.isEmpty(event.id);
          })
        : [];

      digestEvents.sort(function (left, right) {
        return moment(left.start).valueOf() - moment(right.start).valueOf();
      });

      $('#calendarDigestTitle').text((currentViewTitle(view) || 'この表示範囲') + 'の予約一覧');
      $('#calendarDigestCount').text(digestEvents.length + '件');

      if (digestEvents.length === 0) {
        digestList.html('<div class="calendar-digest__empty">この表示範囲に予約はありません。</div>');
        return;
      }

      var html = _.map(digestEvents.slice(0, 10), function (event) {
        var start = moment(event.start);
        var end = moment(event.end);
        var dateLabel = start.format('M/D') + ' ' + _options.dayNamesShort[start.day()];
        var timeLabel = start.format('H:mm') + ' - ' + end.format('H:mm');
        var title = plainTextReservationTitle(event.title);
        if (_.isEmpty(title)) {
          title = '予定';
        }

        return (
          '<a class="calendar-digest__item" href="' +
          escapeHtml(getEventHref(event, view)) +
          '">' +
          '<span class="calendar-digest__date">' +
          escapeHtml(dateLabel) +
          '</span>' +
          '<span class="calendar-digest__time">' +
          escapeHtml(timeLabel) +
          '</span>' +
          '<span class="calendar-digest__name">' +
          escapeHtml(title) +
          '</span>' +
          '</a>'
        );
      }).join('');

      if (digestEvents.length > 10) {
        html +=
          '<div class="calendar-digest__more">表示中の予約は ' +
          digestEvents.length +
          ' 件あります。詳細は月間カレンダーまたは時間割ビューで確認できます。</div>';
      }

      digestList.html(html);
    }

    function updateCalendarActions() {
      var currentDate = normalizedCurrentDate();
      var sid = _options.eventsData.sid || '';
      var rid = _options.eventsData.rid || '';
      var gid = _options.eventsData.gid || '';
      var scheduleLink = $('#calendarOpenSchedule');
      var createShortcut = $('#calendarCreateShortcut');
      var params = [];

      if (!_.isEmpty(sid)) {
        params.push('sid=' + encodeURIComponent(sid));
      }

      if (!_.isEmpty(rid)) {
        params.push('rid=' + encodeURIComponent(rid));
      }

      if (!_.isEmpty(gid)) {
        params.push('gid=' + encodeURIComponent(gid));
      }

      if (!_.isEmpty(currentDate)) {
        params.push('sd=' + encodeURIComponent(currentDate));
      }

      scheduleLink.attr('href', 'schedule.php' + (params.length > 0 ? '?' + params.join('&') : ''));

      if (!_.isEmpty(rid)) {
        createShortcut
          .attr(
            'href',
            _options.reservationUrl +
              '&sd=' +
              encodeURIComponent(currentDate) +
              '&ed=' +
              encodeURIComponent(currentDate)
          )
          .removeClass('calendar-filter__action--disabled')
          .attr('aria-disabled', 'false')
          .text('この会議室で新規予約');
      } else {
        createShortcut
          .attr('href', '#')
          .addClass('calendar-filter__action--disabled')
          .attr('aria-disabled', 'true')
          .text('会議室を選ぶと直接予約できます');
      }
    }

    function updateCalendarSummary(view) {
      $('#calendarCurrentTarget').text(getSelectedFilterText());
      $('#calendarCurrentRange').text(currentViewTitle(view) || '月間表示');

      var visibleEvents = _fullCalendar
        ? _fullCalendar.fullCalendar('clientEvents', function (event) {
            return !_.isEmpty(event.id);
          })
        : [];
      $('#calendarVisibleCount').text(visibleEvents.length + '件');

      updateCalendarActions();
      renderCalendarDigest(view);
    }

    function showLoadingIndicator() {
      elements.loadingIndicator.removeClass('d-none');
    }

    function hideLoadingIndicator() {
      elements.loadingIndicator.addClass('d-none');
    }

    _fullCalendar = $('#calendar').fullCalendar({
      header: {
        left: 'prev,next,today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay',
      },
      buttonText: {
        today: _options.todayText,
        month: _options.monthText,
        week: _options.weekText,
        day: _options.dayText,
      },
      allDaySlot: false,
      weekNumbers: _options.showWeekNumbers,
      defaultView: _options.view,
      defaultDate: _options.defaultDate,
      eventSources: [
        {
          url: _options.eventsUrl,
          type: 'GET',
          data: _options.eventsData,
        },
      ],
      eventRender: function (event, element, view) {
        if (!_.isEmpty(event.id)) {
          element.attachReservationPopup(event.id);
          element.addClass('calendar-event-card');
          element.attr('href', getEventHref(event, view));
          element.attr('title', plainTextReservationTitle(event.title || ''));
        }
      },
      dayClick: dayClick,
      dayNames: _options.dayNames,
      dayNamesShort: _options.dayNamesShort,
      monthNames: _options.monthNames,
      monthNamesShort: _options.monthNamesShort,
      timeFormat: _options.timeFormat,
      firstDay: _options.firstDay,
      views: {
        agendaDay: { slotLabelFormat: _options.timeFormat },
        agendaWeek: { slotLabelFormat: _options.timeFormat },
      },
      viewRender: function (view) {
        updateCalendarSummary(view);
      },
      eventAfterAllRender: function (view) {
        updateCalendarSummary(view);
      },
      slotLabelFormat: _options.timeFormat,
      loading: function (isLoading) {
        if (isLoading) {
          showLoadingIndicator();
        } else {
          hideLoadingIndicator();
        }
      },
      eventDrop: function (event, delta, revertFunc) {
        var handleMoveResponse = function (result) {
          hideLoadingIndicator();
          if (result.errors.length > 0) {
            revertFunc();

            var messages = result.errors.join('</li><li>');
            messages = '<li>' + messages + '</li>';
            elements.moveErrorsList.empty().append(messages);
            elements.moveErrorDialog.modal('show');
          }
        };

        elements.moveReferenceNumber.val(event.id);
        elements.moveStartDate.val(event.start.format('YYYY-MM-DD HH:mm'));
        ajaxPost(elements.moveReservationForm, _options.moveReservationUrl, showLoadingIndicator, handleMoveResponse);
      },
    });

    $('.fc-widget-content').hover(
      function () {
        $(this).addClass('hover');
      },

      function () {
        $(this).removeClass('hover');
      }
    );

    $('.reservation').each(function (index, value) {
      var refNum = $(this).attr('refNum');
      value.attachReservationPopup(refNum);
    });

    $('#calendarFilter').on('change', function () {
      var sid = '';
      var rid = '';
      var gid = getQueryStringValue('gid');

      if ($(this).find(':selected').hasClass('schedule')) {
        sid = $(this).val().replace('s', '');
      } else {
        sid = $(this).find(':selected').prevAll('.schedule').val().replace('s', '');
        rid = $(this).val().replace('r', '');
      }

      _options.eventsData.sid = sid;
      _options.eventsData.rid = rid;
      _options.eventsData.gid = gid;
      _options.dayClickUrl = _options.dayClickUrlTemplate
        .replace('[sid]', sid)
        .replace('[rid]', rid)
        .replace('[gid]', gid);
      _options.reservationUrl = _options.reservationUrlTemplate
        .replace('[sid]', sid)
        .replace('[rid]', rid)
        .replace('[gid]', gid);
      _fullCalendar.fullCalendar('refetchEvents');

      rebindSubscriptionData(rid, sid, gid);
    });

    $('#calendarCreateShortcut').on('click', function (e) {
      if ($(this).hasClass('calendar-filter__action--disabled')) {
        e.preventDefault();
      }
    });

    $('#subscriptionContainer').on('click', '#turnOffSubscription', function (e) {
      e.preventDefault();
      PerformAsyncAction(
        $(this),
        function () {
          return opts.subscriptionDisableUrl;
        },
        null,
        function () {
          return rebindSubscriptionData('', '', '');
        }
      );
    });

    $('#subscriptionContainer').on('click', '#turnOnSubscription', function (e) {
      e.preventDefault();
      PerformAsyncAction(
        $(this),
        function () {
          return opts.subscriptionEnableUrl;
        },
        null,
        function () {
          return rebindSubscriptionData('', '', '');
        }
      );
    });

    dayDialog.find('a').click(function (e) {
      e.preventDefault();
    });

    $('#dayDialogCancel').click(function (e) {
      dayDialog.addClass('d-none');
    });

    $('#dayDialogView').click(function (e) {
      drillDownClick();
    });

    $('#dayDialogCreate').click(function (e) {
      openNewReservation();
    });

    $('#showResourceGroups').click(function (e) {
      e.preventDefault();

      var resourceGroupsContainer = $('#resourceGroupsContainer');

      if (resourceGroupsContainer.is(':visible')) {
        resourceGroupsContainer.hide();
      } else {
        if (!resourceGroupsContainer.data('positionSet')) {
          resourceGroupsContainer.position({ my: 'left top', at: 'right bottom', of: '#showResourceGroups' });
        }
        resourceGroupsContainer.data('positionSet', true);
        resourceGroupsContainer.show();
      }
    });

    elements.moveErrorOk.click(function (e) {
      e.preventDefault();
      elements.moveErrorDialog.modal('hide');
    });

    function selectOwner(ui, textbox) {
      textbox.val(ui.item.label);
      _options.eventsData.uid = ui.item.value;
      _fullCalendar.fullCalendar('refetchEvents');
    }

    function selectParticipant(ui, textbox) {
      textbox.val(ui.item.label);
      _options.eventsData.pid = ui.item.value;
      _fullCalendar.fullCalendar('refetchEvents');
    }

    const ownerFilter = $('#ownerFilter');
    const participantFilter = $('#participantFilter');

    if (ownerFilter.length !== 0) {
      ownerFilter.userAutoComplete(opts.autocompleteUrl, selectOwner);
    }

    if (participantFilter.length !== 0) {
      participantFilter.userAutoComplete(opts.autocompleteUrl, selectParticipant);
    }

    $('#clearUserFilter').on('click', function (e) {
      _options.eventsData.uid = null;
      _options.eventsData.pid = null;
      ownerFilter.val('');
      participantFilter.val('');
      _fullCalendar.fullCalendar('refetchEvents');
    });

    updateCalendarSummary(_fullCalendar.fullCalendar('getView'));
  };

  Calendar.prototype.bindResourceGroups = function (resourceGroups, selectedNode) {
    if (resourceGroups.length == 0) {
      $('#showResourceGroups').hide();
      return;
    }

    // this is copied out of schedule.js, so this needs to be fixed

    function ChangeGroup(groupId) {
      RedirectToSelf('gid', /gid=\d+/i, 'gid=' + groupId, RemoveResourceId);
    }

    function ChangeResource(resourceId) {
      RedirectToSelf('rid', /rid=\d+/i, 'rid=' + resourceId, RemoveGroupId);
    }

    function RemoveResourceId(url) {
      if (!url) {
        url = window.location.href;
      }
      return url.replace(/&*rid=\d+/i, '');
    }

    function RemoveGroupId(url) {
      return url.replace(/&*gid=\d+/i, '');
    }

    function RedirectToSelf(queryStringParam, regexMatch, substitution, preProcess) {
      var url = window.location.href;
      var newUrl = window.location.href;

      if (preProcess) {
        newUrl = preProcess(url);
        newUrl = newUrl.replace(/&{2,}/i, '');
      }

      if (newUrl.indexOf(queryStringParam + '=') != -1) {
        newUrl = newUrl.replace(regexMatch, substitution);
      } else if (newUrl.indexOf('?') != -1) {
        newUrl = newUrl + '&' + substitution;
      } else {
        newUrl = newUrl + '?' + substitution;
      }

      newUrl = newUrl.replace('#', '');

      window.location = newUrl;
    }

    var groupDiv = $('#resourceGroups');
    groupDiv.tree({
      data: resourceGroups,
      saveState: 'resourceCalendar',

      onCreateLi: function (node, $li) {
        if (node.type == 'resource') {
          $li.addClass('group-resource');
        }
      },
    });

    groupDiv.bind('tree.select', function (event) {
      if (event.node) {
        var node = event.node;
        if (node.type == 'resource') {
          ChangeResource(node.resource_id);
        } else {
          ChangeGroup(node.id);
        }
      }
    });

    if (selectedNode) {
      groupDiv.tree('openNode', groupDiv.tree('getNodeById', selectedNode));
    }
  };

  var dayClick = function (date, jsEvent, view) {
    dateVar = date;

    if (!opts.reservable) {
      drillDownClick();
      return;
    }

    if (view.name.indexOf('Day') > 0) {
      handleTimeClick();
    } else {
      //dayDialog.dialog({modal: false, height: 70, width: 'auto'});
      dayDialog.removeClass('d-none');
      dayDialog.position({
        my: 'left bottom',
        at: 'left top',
        of: jsEvent,
      });
    }
  };

  var handleTimeClick = function () {
    openNewReservation();
  };

  var rebindSubscriptionData = function (rid, sid, gid) {
    var url = _options.getSubscriptionUrl + '&rid=' + rid + '&sid=' + sid + '&gid=' + gid;
    ajaxGet(
      url,
      function () {},
      function (response) {
        $('#calendarSubscription').html(response);
      }
    );
  };

  var drillDownClick = function () {
    var month = dateVar.month() + 1;
    var url = _options.dayClickUrl;
    url = url + '&start=' + dateVar.year() + '-' + month + '-' + dateVar.date();

    window.location = url;
  };

  var openNewReservation = function () {
    var view = _fullCalendar.fullCalendar('getView');
    var end = moment(dateVar).add(30, 'minutes');
    var year = dateVar.year();
    var month = dateVar.month() + 1;
    var day = dateVar.date();

    var url =
      _options.reservationUrl +
      '&sd=' +
      getUrlFormattedDate(dateVar) +
      '&ed=' +
      getUrlFormattedDate(end) +
      '&redirect=' +
      _options.returnTo +
      encodeURIComponent('?ct=' + view.name + '&start=' + year + '-' + month + '-' + day);
    window.location = url;
  };

  var getUrlFormattedDate = function (d) {
    var month = d.month() + 1;
    return encodeURI(d.year() + '-' + month + '-' + d.date() + ' ' + d.hour() + ':' + d.minute());
  };
}
