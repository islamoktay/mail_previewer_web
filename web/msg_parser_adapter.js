(function () {
  const SUBJECT_TAG = '__substg1.0_0037001F';
  const SENDER_NAME_TAG = '__substg1.0_0C1A001F';
  const SENDER_EMAIL_TAG = '__substg1.0_0C1F001F';
  const TO_TAG = '__substg1.0_0E04001F';
  const SENT_DATE_TAG = '__substg1.0_0E060040';
  const RECEIVED_DATE_TAG = '__substg1.0_0E070040';
  const BODY_TEXT_TAG = '__substg1.0_1000001F';
  const BODY_HTML_TAG = '__substg1.0_10130102';
  const ATTACHMENT_FOLDER_PREFIX = '__attach_version1.0_';
  const ATTACHMENT_LONG_NAME_TAG = '__substg1.0_3707001F';
  const ATTACHMENT_NAME_TAG = '__substg1.0_3704001F';

  function toUint8Array(content) {
    if (!content) {
      return null;
    }
    if (content instanceof Uint8Array) {
      return content;
    }
    if (Array.isArray(content)) {
      return Uint8Array.from(content);
    }
    if (content.buffer instanceof ArrayBuffer) {
      return new Uint8Array(
        content.buffer,
        content.byteOffset || 0,
        content.byteLength || content.length || 0,
      );
    }
    return null;
  }

  function decodeUtf16Le(content) {
    const bytes = toUint8Array(content);
    if (!bytes || bytes.length === 0) {
      return '';
    }

    const evenLength = bytes.length - (bytes.length % 2);
    const slice = evenLength === bytes.length ? bytes : bytes.slice(0, evenLength);
    return new TextDecoder('utf-16le').decode(slice).replace(/\u0000/g, '');
  }

  function decodeTextBytes(content) {
    const bytes = toUint8Array(content);
    if (!bytes || bytes.length === 0) {
      return '';
    }

    try {
      return new TextDecoder('utf-8').decode(bytes);
    } catch (_) {
      return new TextDecoder('windows-1252').decode(bytes);
    }
  }

  function stripHtml(htmlText) {
    if (!htmlText) {
      return '';
    }
    if (typeof DOMParser === 'undefined') {
      return htmlText.replace(/<[^>]+>/g, ' ');
    }

    const document = new DOMParser().parseFromString(htmlText, 'text/html');
    return document.body ? document.body.textContent || '' : '';
  }

  function normalizeText(value) {
    return (value || '')
      .replace(/\u0000/g, '')
      .replace(/\r\n/g, '\n')
      .replace(/\r/g, '\n')
      .trim();
  }

  function readFileTimeIso(content) {
    const bytes = toUint8Array(content);
    if (!bytes || bytes.length < 8) {
      return null;
    }

    const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const low = BigInt(view.getUint32(0, true));
    const high = BigInt(view.getUint32(4, true));
    const fileTime = (high << 32n) | low;
    if (fileTime === 0n) {
      return null;
    }

    const unixMilliseconds = Number(fileTime / 10000n - 11644473600000n);
    const parsedDate = new Date(unixMilliseconds);
    if (Number.isNaN(parsedDate.getTime())) {
      return null;
    }
    return parsedDate.toISOString();
  }

  function getEntries(msgData) {
    const paths = Array.isArray(msgData && msgData.FullPaths) ? msgData.FullPaths : [];
    const items = Array.isArray(msgData && msgData.FileIndex) ? msgData.FileIndex : [];
    const entries = [];

    for (let index = 0; index < Math.min(paths.length, items.length); index += 1) {
      entries.push({
        path: typeof paths[index] === 'string' ? paths[index] : '',
        item: items[index],
      });
    }

    return entries;
  }

  function findEntryByTag(msgData, tag) {
    return getEntries(msgData).find((entry) => entry.path.endsWith(tag)) || null;
  }

  function readUnicodeProperty(msgData, tag) {
    const entry = findEntryByTag(msgData, tag);
    if (!entry || !entry.item) {
      return '';
    }
    return decodeUtf16Le(entry.item.content);
  }

  function readBinaryProperty(msgData, tag) {
    const entry = findEntryByTag(msgData, tag);
    if (!entry || !entry.item) {
      return '';
    }
    return decodeTextBytes(entry.item.content);
  }

  function readDateProperty(msgData, tag) {
    const entry = findEntryByTag(msgData, tag);
    if (!entry || !entry.item) {
      return null;
    }
    return readFileTimeIso(entry.item.content);
  }

  function getAttachmentNames(msgData) {
    const namesByFolder = new Map();

    for (const entry of getEntries(msgData)) {
      const segments = entry.path.split('/').filter(Boolean);
      if (segments.length !== 3) {
        continue;
      }

      const folderName = segments[1];
      const propertyTag = segments[2];
      if (!folderName.startsWith(ATTACHMENT_FOLDER_PREFIX)) {
        continue;
      }

      if (
        propertyTag !== ATTACHMENT_LONG_NAME_TAG &&
        propertyTag !== ATTACHMENT_NAME_TAG
      ) {
        continue;
      }

      const decodedName = normalizeText(decodeUtf16Le(entry.item && entry.item.content));
      if (!decodedName) {
        continue;
      }

      const existing = namesByFolder.get(folderName);
      if (!existing || propertyTag === ATTACHMENT_LONG_NAME_TAG) {
        namesByFolder.set(folderName, decodedName);
      }
    }

    return Array.from(namesByFolder.values());
  }

  window.parseMsgArchiveSummary = async function parseMsgArchiveSummary(fileBytes) {
    if (!window.DotMsg || !window.DotMsg.DotMsgParser) {
      throw new Error('MSG parser bridge is unavailable.');
    }

    const parser = new window.DotMsg.DotMsgParser();
    await parser.parseBuffer(fileBytes);

    const msgData = parser.getNonNullMsgData();
    const plainTextBody = normalizeText(readUnicodeProperty(msgData, BODY_TEXT_TAG));
    const htmlBody = normalizeText(readBinaryProperty(msgData, BODY_HTML_TAG));

    return {
      subject: normalizeText(readUnicodeProperty(msgData, SUBJECT_TAG)),
      senderName: normalizeText(readUnicodeProperty(msgData, SENDER_NAME_TAG)),
      senderEmail: normalizeText(readUnicodeProperty(msgData, SENDER_EMAIL_TAG)),
      recipients: normalizeText(readUnicodeProperty(msgData, TO_TAG)),
      sentAt:
        readDateProperty(msgData, SENT_DATE_TAG) ||
        readDateProperty(msgData, RECEIVED_DATE_TAG),
      attachmentNames: getAttachmentNames(msgData),
      bodyText: plainTextBody || stripHtml(htmlBody),
    };
  };
})();
