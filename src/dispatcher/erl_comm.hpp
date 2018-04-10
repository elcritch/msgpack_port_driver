typedef char byte;

#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include <climits>
#include <cstring>
#include <iostream>

#include <bitset>         // std::bitset

// just cause -- might run this on embedded devices...
#define IS_LITTLE_ENDIAN (!(*(uint16_t *)"\0\xff" < 0x100))

template <typename T>
T swap_endian(T u)
{
  static_assert (CHAR_BIT == 8, "CHAR_BIT != 8");

  union
  {
    T u;
    byte u8[sizeof(T)];
  } source, dest;

  source.u = u;

  for (size_t k = 0; k < sizeof(T); k++)
  {
      dest.u8[k] = source.u8[sizeof(T) - k - 1];
  }

  return dest.u;
}

/// Read command packet from STDIN
/// the type `PacketLenType` must be the same as the Erlang Packet size (1, 2, or 4 bytes long, eg. byte, uint16_t, or uint32_t respectively)
template <typename PacketLenType>
size_t read_port_cmd(byte *buffer, PacketLenType len)
{

  PacketLenType packet_len = 0;

  std::bitset<32> a(packet_len);

  size_t lens_read = fread(&packet_len,
                              sizeof(PacketLenType),
                              1,
                              stdin);

#ifdef IS_LITTLE_ENDIAN
  packet_len = swap_endian<PacketLenType>(packet_len);
#endif

  // if we can't read sizeof(PacketLenType) byte's, exit
  if (lens_read == 0) {
    return 0;
  }
  else if (lens_read > 1) {
    std::cerr << "Error reading length of cmd packet " << std::endl;
    exit(3);
  }

  if (packet_len >= len) {
    std::cerr << "Packet larger than buffer " << packet_len << std::endl;
    exit(4);
  }

  // if we can't read complete message data, exit
  size_t bytes_read = fread(buffer, 1, packet_len, stdin);

  std::cerr << "Port read: " << bytes_read << std::endl;

  if (bytes_read != packet_len) {
    std::cerr
      << "Read (less) packet bytes than expected "
      << bytes_read
      << packet_len
      << std::endl;

    exit(5);
  }

  return packet_len;
}

/// Write command packet to STDOUT
/// the type `PacketLenType` must be the same as the Erlang Packet size (1, 2, or 4 bytes long, eg. byte, uint16_t, or uint32_t respectively)
template <typename PacketLenType>
size_t write_port_cmd(byte *buffer, PacketLenType packet_len)
{

  PacketLenType len_out = packet_len;

  std::cerr << "Writing bytes: " << len_out << std::endl;

  // swap for endianness
#ifdef IS_LITTLE_ENDIAN
  len_out = swap_endian<PacketLenType>(len_out);
#endif


  std::cerr << "Writing: bytes swapped: " << len_out << std::endl;

  size_t lens_wrote = fwrite(&len_out,
                                sizeof(len_out),
                                1,
                                stdout);

  if (lens_wrote != 1) {
    std::cerr << "Error writing length of data packet" << std::endl;
    exit(13);
  }

  size_t bytes_wrote = fwrite(buffer, sizeof(byte), packet_len, stdout);

  if (bytes_wrote != packet_len) {
    std::cerr
      << "Wrote (less) packet bytes than expected "
      << bytes_wrote * sizeof(byte)
      << " of "
      << packet_len
      << std::endl;

     exit(15);
  }

  fflush(stdout);
  return bytes_wrote;
};

template <typename Dispatcher, typename PacketLenType, size_t BufferSize>
int port_cmd_loop(Dispatcher& disp)
{

  char cmd_buffer[BufferSize];
  PacketLenType max_packet_size = BufferSize;

  do {
    // Get command "packets" from erlang port
    PacketLenType cmd_sz = read_port_cmd<PacketLenType>(cmd_buffer, max_packet_size);

#ifdef ERL_PORT_DEBUG
    std::cerr << "Recieved command buffer: " << cmd_sz << std::endl;
#endif

    if (cmd_sz > 1) {

      msgpack::object_handle oh = msgpack::unpack(cmd_buffer, cmd_sz);
      msgpack::object rpc_obj = oh.get();

#ifdef ERL_PORT_DEBUG
      std::cerr << "Recieved command: " << rpc_obj << std::endl;
#endif

      rpc::detail::response resp = disp.dispatch(rpc_obj);

      if (!resp.is_empty()) {

        msgpack::sbuffer reply = resp.get_data();


#ifdef ERL_PORT_DEBUG
        msgpack::object_handle resp_h =
          msgpack::unpack(reply.data(), reply.size());
        std::cerr << "resp:msg: " << resp_h.get() << std::endl;
#endif

#ifdef ERL_PORT_DEBUG
        std::cerr << "resp:sz: " << reply.size() << std::endl;
#endif

        write_port_cmd<PacketLenType>(reply.data(), reply.size());
      }
    }
  } while(!feof(stdin));

  return 0;
}
